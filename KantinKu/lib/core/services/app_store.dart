import 'package:flutter/material.dart';
import '../../app/app_stage.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/catalog/models/canteen.dart';
import '../../features/catalog/models/food.dart';
import '../../features/order/models/kantin_order.dart';
import '../../shared/models/cart_line.dart';
import '../../shared/models/user_profile.dart';

/// Sumber tunggal state UI foundation. Belum melakukan autentikasi/transaksi.
class AppStore extends ChangeNotifier {
  final List<CartLine> _cart = [];
  final Set<String> _favorites = {};
  bool _previewMode = false;
  String? _pickupSlot, _paymentMethod;

  int get stage => AppStage.current;
  Future<void> initialize() async {}
  List<Food> get foods => CatalogRepository.foods;
  List<Canteen> get canteens => CatalogRepository.canteens;
  List<CartLine> get cartLines => List.unmodifiable(_cart);
  int get subtotal => _cart.fold(0, (sum, line) => sum + line.total);
  int get serviceFee => 0;
  int get total => subtotal + serviceFee;
  int get cartCount => _cart.fold(0, (sum, line) => sum + line.quantity);
  bool get previewMode => _previewMode;
  bool get isLoggedIn => _previewMode;
  bool get busy => false;
  String? get pickupSlot => _pickupSlot;
  String? get paymentMethod => _paymentMethod;
  ThemeMode get themeMode => ThemeMode.light;
  Set<String> get favoriteIds => Set.unmodifiable(_favorites);
  Set<String> get favorites => favoriteIds;
  String get preferredPickupSlot => '12.00–12.15';
  UserProfile? get user => _previewMode ? const UserProfile(id: 'preview',
    name: 'Anjari', email: 'anjari@example.com', phone: '0812 3456 7890',
    institution: 'Universitas Contoh', department: 'Informatika') : null;
  List<KantinOrder> get orders => !_previewMode ? const [] : [KantinOrder(
    id: 'KK-241', userId: 'preview', canteenId: 'kantin_a',
    items: [CartLine(food: foodById('geprek'), quantity: 1, note: 'Tidak terlalu pedas'),
      CartLine(food: foodById('es_teh'), quantity: 1)],
    createdAt: DateTime(2026, 10, 14), pickupSlot: '12.00–12.15',
    paymentMethod: 'QRIS', status: OrderStatus.preparing)];

  Food foodById(String id) => foods.firstWhere((food) => food.id == id);
  Canteen canteenById(String id) => canteens.firstWhere((canteen) => canteen.id == id);
  List<Food> foodsForCanteen(String id) => foods.where((food) => food.canteenId == id).toList();
  void setPreviewMode(bool enabled) { _previewMode = enabled; notifyListeners(); }
  void addToCart(Food food, {int quantity = 1, String note = ''}) {
    if (!food.available || !canteenById(food.canteenId).isOpen) {
      throw StateError('Menu sedang tidak tersedia.');
    }
    if (quantity < 1 || quantity > 99) throw RangeError('Jumlah harus 1–99.');
    if (_cart.isNotEmpty && _cart.first.food.canteenId != food.canteenId) {
      throw StateError('Keranjang hanya dapat berisi menu dari satu kantin.');
    }
    final index = _cart.indexWhere((line) => line.food.id == food.id);
    final newQuantity = quantity + (index >= 0 ? _cart[index].quantity : 0);
    if (newQuantity > 99) throw RangeError('Jumlah maksimal 99 per menu.');
    if (index < 0) { _cart.add(CartLine(food: food, quantity: quantity, note: note)); }
    else { _cart[index] = _cart[index].copyWith(quantity: newQuantity,
      note: note.isEmpty ? _cart[index].note : note); }
    notifyListeners();
  }
  void setQuantity(String foodId, int quantity) {
    if (quantity < 0 || quantity > 99) throw RangeError('Jumlah harus 0–99.');
    if (quantity == 0) { removeFromCart(foodId); return; }
    final index = _cart.indexWhere((line) => line.food.id == foodId);
    if (index < 0) throw StateError('Menu tidak ditemukan di keranjang.');
    _cart[index] = _cart[index].copyWith(quantity: quantity); notifyListeners();
  }
  void setItemNote(String foodId, String note) {
    final index = _cart.indexWhere((line) => line.food.id == foodId);
    if (index < 0) throw StateError('Menu tidak ditemukan di keranjang.');
    _cart[index] = _cart[index].copyWith(note: note); notifyListeners();
  }
  void removeFromCart(String foodId) { _cart.removeWhere((line) => line.food.id == foodId); notifyListeners(); }
  void clearCart() { _cart.clear(); _pickupSlot = null; _paymentMethod = null; notifyListeners(); }
  void setPickupSlot(String? slot) { _pickupSlot = slot; notifyListeners(); }
  void setPaymentMethod(String? method) { _paymentMethod = method; notifyListeners(); }
  void toggleFavorite(String foodId) {
    foodById(foodId);
    if (!_favorites.add(foodId)) _favorites.remove(foodId);
    notifyListeners();
  }
}
