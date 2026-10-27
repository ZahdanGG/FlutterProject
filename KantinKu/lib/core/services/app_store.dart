import 'dart:convert';
import 'package:flutter/material.dart';
import '../../app/app_stage.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/catalog/models/canteen.dart';
import '../../features/catalog/models/food.dart';
import '../../features/order/models/kantin_order.dart';
import '../../shared/models/cart_line.dart';
import '../../shared/models/user_profile.dart';
import 'app_exception.dart';
import 'local_store.dart';
import 'payment_service.dart';

/// State aplikasi local-first. Semua uang memakai int rupiah.
/// Penyimpanan satu dokumen mencegah order tersimpan tanpa pengosongan cart.
class AppStore extends ChangeNotifier {
  AppStore({LocalStore? persistence, AuthRepository? authRepository,
    PaymentService? paymentService, DateTime Function()? clock})
      : _storage = persistence, _clock = clock ?? DateTime.now,
        _auth = authRepository ?? AuthRepository(clock: clock),
        _payment = paymentService ?? const DemoPaymentService();

  static const storageKey = 'kantinku.demo.v2';
  static const pickupSlots = ['11.45–12.00', '12.00–12.15', '12.15–12.30',
    '12.30–12.45', '12.45–13.00', '13.00–13.15'];
  static const paymentMethods = ['QRIS', 'GoPay', 'OVO', 'DANA', 'ShopeePay'];
  LocalStore? _storage;
  final DateTime Function() _clock;
  final AuthRepository _auth;
  final PaymentService _payment;
  final Map<String, _UserData> _users = {};
  _UserData _guest = _UserData();
  String? _currentUserId;
  ThemeMode _themeMode = ThemeMode.light;
  bool _operation = false, _initialized = false, _readFailed = false, _disposed = false;
  String? _persistenceError;
  Future<void> _writes = Future<void>.value();
  Future<void>? _initializing;
  Future<KantinOrder>? _checkoutInFlight;

  int get stage => AppStage.current;
  bool get initialized => _initialized;
  bool get initializationFailed => _readFailed;
  bool get busy => _operation;
  bool get previewMode => false;
  bool get isLoggedIn => user != null;
  UserProfile? get user => _auth.profileById(_currentUserId);
  String? get persistenceError => _persistenceError;
  DateTime get currentTime => _clock();
  DateTime get now => currentTime;
  List<Food> get foods => CatalogRepository.foods;
  List<Canteen> get canteens => CatalogRepository.canteens;
  _UserData get _data => _currentUserId == null ? _guest : _users.putIfAbsent(_currentUserId!, _UserData.new);
  List<CartLine> get cartLines => List.unmodifiable(_data.cart);
  List<CartLine> get pendingGuestCart => isLoggedIn ? List.unmodifiable(_guest.cart) : const [];
  int get subtotal => _data.cart.fold(0, (sum, line) => sum + line.total);
  int get serviceFee => 0;
  int get total => subtotal + serviceFee;
  int get cartCount => _data.cart.fold(0, (sum, line) => sum + line.quantity);
  String? get pickupSlot => _data.pickupSlot;
  String? get paymentMethod => _data.paymentMethod;
  DateTime get pickupDate {
    final selected = _data.pickupDate;
    if (selected != null) return selected;
    final today = _dateOnly(now);
    return pickupSlots.any((slot) => isPickupSlotAvailable(slot, date: today))
        ? today : today.add(const Duration(days: 1));
  }
  ThemeMode get themeMode => stage >= 3 ? _themeMode : ThemeMode.light;
  Set<String> get favoriteIds => Set.unmodifiable(_data.favoriteIds);
  Set<String> get favorites => favoriteIds;
  Set<String> get favoriteCanteenIds => Set.unmodifiable(_data.favoriteCanteenIds);
  String get preferredPickupSlot => _data.preferredPickupSlot;
  bool get notificationsEnabled => _data.notificationsEnabled;
  List<KantinOrder> get orders => List.unmodifiable(_data.orders);
  Food foodById(String id) => foods.firstWhere((food) => food.id == id);
  Canteen canteenById(String id) => canteens.firstWhere((canteen) => canteen.id == id);
  List<Food> foodsForCanteen(String id) => foods.where((food) => food.canteenId == id).toList();
  KantinOrder orderById(String id) => _data.orders.firstWhere((order) => order.id == id,
    orElse: () => throw const AppException('Pesanan tidak ditemukan pada akun ini.'));

  Future<void> initialize() => _initializing ??= _load();
  Future<void> _load() async {
    try {
      _storage ??= await PreferencesLocalStore.create();
      final raw = await _storage!.read(storageKey);
      if (raw != null) _restore(raw);
      _readFailed = false;
      _persistenceError = null;
    } catch (_) {
      // Keep the stored document untouched; expose a retry rather than silently
      // replacing damaged or temporarily inaccessible data with an empty account.
      _auth.restore({'accounts': <dynamic>[]});
      _users.clear(); _guest = _UserData(); _currentUserId = null;
      _themeMode = ThemeMode.light;
      _readFailed = true;
      _persistenceError = 'Data lokal tidak dapat dibaca. Data lama dipertahankan. Coba muat ulang penyimpanan.';
    }
    _initialized = true;
    if (!_readFailed && _expirePendingOrders()) {
      try { await _saveNow(); } on AppException { /* banner exposes the failure */ }
    }
    _notify();
  }
  Future<void> retryInitialization() async {
    if (_operation) throw const AppException('Proses sebelumnya masih berjalan.');
    _initialized = false;
    _initializing = null;
    await initialize();
    if (_readFailed) throw AppException(_persistenceError!);
  }
  Future<void> retryPendingWrites() => flush();

  // Stage1-only call retained for source compatibility; never grants demo auth.
  void setPreviewMode(bool enabled) {
    if (enabled) throw const AppException('Preview akun hanya tersedia pada ZIP 1. Daftar akun demo untuk masuk.');
  }

  void addToCart(Food food, {int quantity = 1, String note = ''}) {
    _checkMutable();
    final actual = foodById(food.id);
    if (!actual.available || !canteenById(actual.canteenId).isOpen) {
      throw StateError('Menu sedang tidak tersedia.');
    }
    if (quantity < 1 || quantity > 99) throw RangeError('Jumlah harus 1–99.');
    if (_data.cart.isNotEmpty && _data.cart.first.food.canteenId != actual.canteenId) {
      throw StateError('Keranjang hanya dapat berisi menu dari satu kantin.');
    }
    final index = _data.cart.indexWhere((line) => line.food.id == actual.id);
    final newQuantity = quantity + (index >= 0 ? _data.cart[index].quantity : 0);
    if (newQuantity > 99) throw RangeError('Jumlah maksimal 99 per menu.');
    if (index < 0) {
      _data.cart.add(CartLine(food: actual, quantity: quantity, note: note.trim()));
    } else {
      _data.cart[index] = _data.cart[index].copyWith(quantity: newQuantity,
        note: note.trim().isEmpty ? _data.cart[index].note : note.trim());
    }
    _changed();
  }
  void setQuantity(String foodId, int quantity) {
    _checkMutable();
    if (quantity < 0 || quantity > 99) throw RangeError('Jumlah harus 0–99.');
    if (quantity == 0) { removeFromCart(foodId); return; }
    final index = _data.cart.indexWhere((line) => line.food.id == foodId);
    if (index < 0) throw StateError('Menu tidak ditemukan di keranjang.');
    _data.cart[index] = _data.cart[index].copyWith(quantity: quantity);
    _changed();
  }
  void setItemNote(String foodId, String note) {
    _checkMutable();
    final index = _data.cart.indexWhere((line) => line.food.id == foodId);
    if (index < 0) throw StateError('Menu tidak ditemukan di keranjang.');
    _data.cart[index] = _data.cart[index].copyWith(note: note.trim());
    _changed();
  }
  void removeFromCart(String foodId) {
    _checkMutable();
    _data.cart.removeWhere((line) => line.food.id == foodId);
    if (_data.cart.isEmpty) { _data.pickupSlot = null; _data.paymentMethod = null; }
    _changed();
  }
  void clearCart() {
    _checkMutable();
    _data.cart.clear(); _data.pickupSlot = null; _data.paymentMethod = null;
    _changed();
  }
  void setPickupSlot(String? slot) {
    _checkMutable();
    if (slot != null && !pickupSlots.contains(slot)) throw const AppException('Slot waktu tidak valid.');
    _data.pickupSlot = slot;
    _changed();
  }
  void setPickupDate(DateTime date) {
    _checkMutable();
    final day = _dateOnly(date);
    final today = _dateOnly(now);
    if (day.isBefore(today) || day.isAfter(today.add(const Duration(days: 1)))) {
      throw const AppException('Pilih tanggal hari ini atau besok.');
    }
    _data.pickupDate = day;
    if (_data.pickupSlot != null && !isPickupSlotAvailable(_data.pickupSlot!, date: day)) {
      _data.pickupSlot = null;
    }
    _changed();
  }
  bool isPickupSlotAvailable(String slot, {DateTime? date}) {
    if (!pickupSlots.contains(slot) || slot == pickupSlots.first || slot == pickupSlots.last) return false;
    final day = _dateOnly(date ?? pickupDate);
    final today = _dateOnly(now);
    if (day.isBefore(today) || day.isAfter(today.add(const Duration(days: 1)))) return false;
    final parts = slot.split('–').first.split('.');
    final start = DateTime(day.year, day.month, day.day, int.parse(parts[0]), int.parse(parts[1]));
    return !start.isBefore(now.add(const Duration(minutes: 20)));
  }
  void setPaymentMethod(String? method) {
    _checkMutable();
    if (method != null && !paymentMethods.contains(method)) throw const AppException('Metode pembayaran tidak valid.');
    _data.paymentMethod = method;
    _changed();
  }
  void toggleFavorite(String foodId) {
    _checkMutable(); foodById(foodId);
    if (!_data.favoriteIds.add(foodId)) _data.favoriteIds.remove(foodId);
    _changed();
  }
  void toggleFavoriteCanteen(String id) {
    _checkMutable(); canteenById(id);
    if (!_data.favoriteCanteenIds.add(id)) _data.favoriteCanteenIds.remove(id);
    _changed();
  }

  Future<void> register({required String name, required String email,
    required String password, required String confirmPassword, required String role,
    String phone = '', String institution = '', String department = '',
    String studentId = '', String staffId = ''}) => _transaction(() async {
      final profile = await _auth.register(name: name, email: email, password: password,
        confirmPassword: confirmPassword, role: role, phone: phone, institution: institution,
        department: department, studentId: studentId, staffId: staffId);
      _startSession(profile.id);
    });
  Future<void> login({required String email, required String password}) => _transaction(() async {
    final profile = await _auth.login(email: email, password: password);
    _startSession(profile.id);
  });
  void _startSession(String id) {
    _currentUserId = id;
    // Retain the guest's choice. An existing account cart is never overwritten.
    if (_data.cart.isEmpty && _guest.cart.isNotEmpty) {
      _data.cart.addAll(_guest.cart);
      _data.pickupSlot = _guest.pickupSlot;
      _data.pickupDate = _guest.pickupDate;
      _data.paymentMethod = _guest.paymentMethod;
      _guest.cart.clear();
    }
    _data.favoriteIds.addAll(_guest.favoriteIds);
    _data.favoriteCanteenIds.addAll(_guest.favoriteCanteenIds);
    _guest.favoriteIds.clear(); _guest.favoriteCanteenIds.clear();
  }
  Future<void> restoreGuestCart({bool replace = false}) => _transaction(() async {
    _requireLogin();
    if (_guest.cart.isEmpty) return;
    if (_data.cart.isNotEmpty && !replace) {
      throw const AppException('Konfirmasikan penggantian keranjang akun terlebih dahulu.');
    }
    _data.cart..clear()..addAll(_guest.cart);
    _data.pickupSlot = _guest.pickupSlot; _data.pickupDate = _guest.pickupDate;
    _data.paymentMethod = _guest.paymentMethod;
    _guest.cart.clear();
  });
  Future<void> logout() => _transaction(() async { _currentUserId = null; });
  Future<String> requestPasswordReset(String email) => _transaction(() => _auth.requestPasswordReset(email));
  Future<void> resetPassword({required String email, required String token,
    required String password, required String confirmPassword}) => _transaction(() async {
      await _auth.resetPassword(email: email, token: token, password: password, confirmPassword: confirmPassword);
      if (user?.email == AuthRepository.normalizeEmail(email)) _currentUserId = null;
    });
  Future<void> updateProfile(UserProfile updated) => _transaction(() async {
    _requireLogin();
    if (updated.id != _currentUserId) throw const AppException('Profil tidak sesuai dengan akun aktif.');
    _auth.updateProfile(updated);
  });
  Future<void> changePassword({required String currentPassword,
    required String password, required String confirmPassword}) => _transaction(() async {
      _requireLogin();
      await _auth.changePassword(userId: _currentUserId!, currentPassword: currentPassword,
        password: password, confirmPassword: confirmPassword);
    });

  Future<KantinOrder> checkout() {
    // Both taps share the exact same future, so no second order can be made.
    if (_checkoutInFlight != null) return _checkoutInFlight!;
    final future = _transaction<KantinOrder>(() async {
      _requireLogin();
      if (_data.cart.isEmpty) throw const AppException('Keranjang masih kosong.');
      if (_data.pickupSlot == null || !isPickupSlotAvailable(_data.pickupSlot!)) {
        throw const AppException('Pilih waktu ambil yang tersedia, minimal 20 menit dari sekarang.');
      }
      if (_data.paymentMethod == null || !paymentMethods.contains(_data.paymentMethod)) {
        throw const AppException('Pilih metode pembayaran.');
      }
      final canteenId = _data.cart.first.food.canteenId;
      if (!canteenById(canteenId).isOpen) throw const AppException('Kantin sedang tutup.');
      for (final line in _data.cart) {
        final current = foodById(line.food.id);
        if (!current.available || current.canteenId != canteenId || line.quantity < 1 || line.quantity > 99) {
          throw const AppException('Isi keranjang berubah atau tidak tersedia. Periksa keranjang.');
        }
      }
      final order = KantinOrder(id: _newOrderId(), userId: _currentUserId!, canteenId: canteenId,
        items: List.unmodifiable(_data.cart), createdAt: now, pickupDate: pickupDate,
        pickupSlot: _data.pickupSlot!, paymentMethod: _data.paymentMethod!, paymentStartedAt: now);
      _data.orders.insert(0, order);
      _data.cart.clear(); _data.pickupSlot = null; _data.paymentMethod = null;
      return order;
    });
    _checkoutInFlight = future;
    // Handling both outcomes avoids an unobserved future from whenComplete.
    future.then<void>((_) { _checkoutInFlight = null; }, onError: (Object _, StackTrace __) {
      _checkoutInFlight = null;
    });
    return future;
  }

  Future<void> simulatePayment(String orderId, {required bool success}) async {
    await refreshOrderExpiry();
    await _transaction(() async {
      _requireLogin();
      final order = orderById(orderId);
      if (order.isPaid && success) return; // Repeat confirmation is harmless.
      if (!order.canPay) throw const AppException('Pesanan tidak dapat dibayar pada status ini.');
      final paid = await _payment.simulate(orderId: order.id, amount: order.total, success: success);
      if (!now.isBefore(order.expiresAt)) {
        _replaceOrder(order.copyWith(status: OrderStatus.expired));
      } else {
        _replaceOrder(order.copyWith(status: paid ? OrderStatus.confirmed : OrderStatus.failed,
          paidAt: paid ? now : null));
      }
    });
  }
  Future<void> retryPayment(String orderId, {String? paymentMethod}) async {
    await refreshOrderExpiry();
    await _transaction(() async {
      _requireLogin();
      final order = orderById(orderId);
      if (order.status != OrderStatus.failed && order.status != OrderStatus.pending) {
        throw const AppException('Pesanan tidak dapat dicoba ulang. Buat pesanan baru bila kedaluwarsa.');
      }
      final method = paymentMethod ?? order.paymentMethod;
      if (!paymentMethods.contains(method)) throw const AppException('Metode pembayaran tidak valid.');
      _replaceOrder(order.copyWith(status: OrderStatus.pending, paymentMethod: method,
        paymentStartedAt: order.status == OrderStatus.failed ? now : order.paymentStartedAt));
    });
  }
  Future<void> transitionOrder(String orderId, OrderStatus next) async {
    await refreshOrderExpiry();
    await _transaction(() async {
      _requireLogin();
      final order = orderById(orderId);
      // Payment confirmation must go through PaymentService, never this shortcut.
      if (next == OrderStatus.confirmed || next == OrderStatus.pending ||
          !order.status.canTransitionTo(next)) {
        throw const AppException('Perubahan status pesanan tidak diizinkan.');
      }
      _replaceOrder(order.copyWith(status: next));
    });
  }
  Future<void> cancelOrder(String orderId) => transitionOrder(orderId, OrderStatus.cancelled);
  Future<void> refreshOrderExpiry() async {
    if (!_initialized || _operation || _readFailed) return;
    final needsUpdate = _users.values.any((data) => data.orders.any((order) =>
      order.status == OrderStatus.pending && !now.isBefore(order.expiresAt)));
    if (!needsUpdate) return;
    await _transaction(() async { _expirePendingOrders(); });
  }
  bool _expirePendingOrders() {
    var changed = false;
    for (final data in _users.values) {
      for (var index = 0; index < data.orders.length; index++) {
        final order = data.orders[index];
        if (order.status == OrderStatus.pending && !now.isBefore(order.expiresAt)) {
          data.orders[index] = order.copyWith(status: OrderStatus.expired);
          changed = true;
        }
      }
    }
    return changed;
  }
  Future<void> reorder(String orderId) => _transaction(() async {
    _requireLogin();
    final source = orderById(orderId);
    if (!canteenById(source.canteenId).isOpen) throw const AppException('Kantin sedang tutup.');
    final refreshed = <CartLine>[];
    for (final line in source.items) {
      final food = foodById(line.food.id);
      if (!food.available) throw AppException('${food.name} sedang tidak tersedia.');
      refreshed.add(CartLine(food: food, quantity: line.quantity, note: line.note));
    }
    _data.cart..clear()..addAll(refreshed);
    _data.pickupSlot = null; _data.pickupDate = null; _data.paymentMethod = null;
  });
  void _replaceOrder(KantinOrder order) {
    final index = _data.orders.indexWhere((item) => item.id == order.id);
    if (index < 0) throw const AppException('Pesanan tidak ditemukan.');
    _data.orders[index] = order;
  }

  Future<void> setThemeMode(ThemeMode mode) => _transaction(() async { _themeMode = mode; });
  Future<void> setPreferredPickupSlot(String slot) => _transaction(() async {
    if (!pickupSlots.contains(slot)) throw const AppException('Preferensi waktu tidak valid.');
    _data.preferredPickupSlot = slot;
  });
  Future<void> setNotificationsEnabled(bool enabled) => _transaction(() async {
    _data.notificationsEnabled = enabled;
  });

  Future<void> flush() async {
    await _writes;
    if (_readFailed) throw AppException(_persistenceError!);
    if (_persistenceError != null) await _saveNow();
  }
  Future<T> _transaction<T>(Future<T> Function() operation) async {
    _checkMutable();
    if (!_initialized || _storage == null) throw const AppException('Penyimpanan belum siap. Coba lagi.');
    _operation = true; _notify();
    String? before;
    try {
      await _writes;
      before = _serialize();
      final result = await operation();
      await _saveNow();
      return result;
    } catch (error) {
      if (before != null) _restore(before);
      if (error is AppException || error is StateError || error is RangeError) rethrow;
      throw const AppException('Perubahan belum tersimpan. Silakan coba kembali.');
    } finally {
      _operation = false; _notify();
    }
  }
  void _changed() {
    _notify();
    if (!_initialized || _storage == null || _readFailed) return;
    final snapshot = _serialize();
    _writes = _writes.then((_) async {
      try {
        await _storage!.write(storageKey, snapshot);
        _persistenceError = null;
      } catch (_) {
        _persistenceError = 'Perubahan belum tersimpan. Periksa ruang penyimpanan perangkat.';
      }
      _notify();
    });
  }
  Future<void> _saveNow() async {
    try {
      await _storage!.write(storageKey, _serialize());
      _persistenceError = null;
    } catch (_) {
      _persistenceError = 'Perubahan belum tersimpan. Periksa ruang penyimpanan perangkat.';
      throw AppException(_persistenceError!);
    }
  }
  void _checkMutable() {
    if (_operation) throw const AppException('Proses sebelumnya masih berjalan.');
    if (_readFailed) throw AppException(_persistenceError!);
  }
  void _requireLogin() {
    if (!isLoggedIn) throw const AppException('Masuk dahulu untuk melanjutkan.');
  }
  String _newOrderId() {
    // Local demo sequence stays readable like the Figma examples. The same
    // transaction lock and document cover every account on this device.
    final used = _users.values.expand((data) => data.orders).map((order) => order.id).toSet();
    var serial = 241;
    while (used.contains('KK-$serial')) { serial++; }
    return 'KK-$serial';
  }
  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
  String _serialize() => jsonEncode({'schema': 2, 'auth': _auth.toJson(),
    'currentUserId': _currentUserId, 'themeMode': _themeMode.name,
    'guest': _guest.toJson(), 'users': _users.map((id, data) => MapEntry(id, data.toJson()))});
  void _restore(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    if (json['schema'] != 2) throw const FormatException('Unsupported local schema');
    _auth.restore(Map<String, dynamic>.from(json['auth'] as Map));
    _users.clear();
    for (final entry in (json['users'] as Map).entries) {
      _users[entry.key as String] = _UserData.fromJson(Map<String, dynamic>.from(entry.value as Map));
    }
    _guest = _UserData.fromJson(Map<String, dynamic>.from(json['guest'] as Map));
    _normalizeCart(_guest);
    for (final data in _users.values) { _normalizeCart(data); }
    _currentUserId = json['currentUserId'] as String?;
    if (_auth.profileById(_currentUserId) == null) _currentUserId = null;
    _themeMode = ThemeMode.values.byName(json['themeMode'] as String? ?? 'light');
  }
  void _normalizeCart(_UserData data) {
    final refreshed = <CartLine>[];
    for (final line in data.cart) {
      if (line.quantity < 1 || line.quantity > 99) throw const FormatException('Invalid quantity');
      final food = foodById(line.food.id);
      if (refreshed.isNotEmpty && refreshed.first.food.canteenId != food.canteenId) {
        throw const FormatException('Mixed canteens');
      }
      refreshed.add(CartLine(food: food, quantity: line.quantity, note: line.note));
    }
    data.cart..clear()..addAll(refreshed);
  }
  void _notify() { if (!_disposed) notifyListeners(); }
  @override
  void dispose() { _disposed = true; super.dispose(); }
}

class _UserData {
  final List<CartLine> cart = [];
  final List<KantinOrder> orders = [];
  final Set<String> favoriteIds = {}, favoriteCanteenIds = {};
  String? pickupSlot, paymentMethod;
  DateTime? pickupDate;
  String preferredPickupSlot = '12.00–12.15';
  bool notificationsEnabled = true;
  Map<String, dynamic> toJson() => {'cart': cart.map((e) => e.toJson()).toList(),
    'orders': orders.map((e) => e.toJson()).toList(), 'favoriteIds': favoriteIds.toList(),
    'favoriteCanteenIds': favoriteCanteenIds.toList(), 'pickupSlot': pickupSlot,
    'paymentMethod': paymentMethod, 'pickupDate': pickupDate?.toIso8601String(),
    'preferredPickupSlot': preferredPickupSlot, 'notificationsEnabled': notificationsEnabled};
  static _UserData fromJson(Map<String, dynamic> json) {
    final data = _UserData();
    data.cart.addAll((json['cart'] as List? ?? const []).map((e) => CartLine.fromJson(Map<String, dynamic>.from(e as Map))));
    data.orders.addAll((json['orders'] as List? ?? const []).map((e) => KantinOrder.fromJson(Map<String, dynamic>.from(e as Map))));
    data.favoriteIds.addAll((json['favoriteIds'] as List? ?? const []).cast<String>());
    data.favoriteCanteenIds.addAll((json['favoriteCanteenIds'] as List? ?? const []).cast<String>());
    data.pickupSlot = json['pickupSlot'] as String?; data.paymentMethod = json['paymentMethod'] as String?;
    data.pickupDate = json['pickupDate'] == null ? null : DateTime.parse(json['pickupDate'] as String);
    data.preferredPickupSlot = json['preferredPickupSlot'] as String? ?? '12.00–12.15';
    data.notificationsEnabled = json['notificationsEnabled'] as bool? ?? true;
    return data;
  }
}
