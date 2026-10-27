import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantinku/app/app_stage.dart';
import 'package:kantinku/core/services/app_exception.dart';
import 'package:kantinku/core/services/app_store.dart';
import 'package:kantinku/core/services/local_store.dart';
import 'package:kantinku/core/services/payment_service.dart';
import 'package:kantinku/features/auth/data/auth_repository.dart';
import 'package:kantinku/features/order/models/kantin_order.dart';

class ImmediatePayment implements PaymentService {
  @override
  Future<bool> simulate({required String orderId, required int amount, required bool success}) async => success;
}
class FailingStore extends MemoryLocalStore {
  bool fail = false;
  @override
  Future<void> write(String key, String value) async {
    if (fail) throw const AppException('Simulated disk failure');
    await super.write(key, value);
  }
}

void main() {
  var time = DateTime(2026, 10, 21, 10);
  AppStore makeStore(LocalStore disk) => AppStore(persistence: disk,
    authRepository: AuthRepository(iterations: 20, clock: () => time),
    paymentService: ImmediatePayment(), clock: () => time);
  Future<void> register(AppStore store, [String email = 'anjari@example.com']) => store.register(
    name: 'Anjari', email: email, password: 'password123', confirmPassword: 'password123', role: 'Mahasiswa');
  void fillCheckout(AppStore store) {
    store.addToCart(store.foodById('geprek'));
    store.addToCart(store.foodById('es_teh'));
    store.setPickupDate(DateTime(2026, 10, 21));
    store.setPickupSlot('12.00–12.15');
    store.setPaymentMethod('QRIS');
  }
  setUp(() { time = DateTime(2026, 10, 21, 10); });

  test('validators reject malformed email, short password and mismatch', () {
    expect(AuthRepository.validateEmail('bad-address'), isNotNull);
    expect(AuthRepository.validateEmail('nama@example.com'), isNull);
    expect(AuthRepository.validatePassword('short'), isNotNull);
    expect(AuthRepository.validateConfirmation('password123', 'different'), isNotNull);
  });
  test('all four visible registration roles create an account', () async {
    final repository = AuthRepository(iterations: 20);
    var index = 0;
    for (final role in ['Mahasiswa', 'Pekerja', 'Dosen/Staf', 'Lainnya']) {
      final profile = await repository.register(name: 'Pengguna Demo',
        email: 'user${index++}@example.com', password: 'password123',
        confirmPassword: 'password123', role: role);
      expect(profile.role, role);
    }
  });
  test('register stores salted hashes, session restores, wrong password rejected', () async {
    final disk = MemoryLocalStore();
    final store = makeStore(disk); await store.initialize();
    await register(store);
    expect(store.isLoggedIn, isTrue);
    final raw = disk.values[AppStore.storageKey]!;
    expect(raw.contains('password123'), isFalse);
    final payload = jsonDecode(raw) as Map;
    final account = ((payload['auth'] as Map)['accounts'] as List).single as Map;
    expect(account['salt'], isNotEmpty); expect(account['passwordHash'], isNotEmpty);
    final restored = makeStore(disk); await restored.initialize();
    expect(restored.user!.email, 'anjari@example.com');
    await restored.logout();
    await expectLater(restored.login(email: 'anjari@example.com', password: 'wrongpass'), throwsA(isA<AppException>()));
    expect(restored.isLoggedIn, isFalse);
    await restored.login(email: ' ANJARI@example.com ', password: 'password123');
    expect(restored.isLoggedIn, isTrue);
    store.dispose(); restored.dispose();
  });
  test('guest cannot checkout, then chosen cart survives registration', () async {
    final store = makeStore(MemoryLocalStore()); await store.initialize();
    fillCheckout(store);
    await expectLater(store.checkout(), throwsA(isA<AppException>()));
    expect(store.cartCount, 2);
    await register(store);
    expect(store.cartCount, 2);
    final order = await store.checkout();
    expect(order.total, 23000); expect(order.status, OrderStatus.pending);
    expect(store.cartCount, 0);
    expect(store.orders, hasLength(1)); store.dispose();
  });
  test('double checkout shares operation and payment/status lifecycle persists', () async {
    final disk = MemoryLocalStore();
    final store = makeStore(disk); await store.initialize(); await register(store);
    fillCheckout(store);
    final first = store.checkout(); final duplicate = store.checkout();
    expect(identical(first, duplicate), isTrue);
    final order = await first;
    await duplicate;
    expect(store.orders, hasLength(1));
    expect(order.pickupCode, isEmpty);
    time = time.add(const Duration(minutes: 2));
    await store.simulatePayment(order.id, success: true);
    expect(store.orderById(order.id).paidAt, time);
    expect(store.orderById(order.id).status, OrderStatus.confirmed);
    expect(store.orderById(order.id).pickupCode, order.id);
    await expectLater(store.transitionOrder(order.id, OrderStatus.completed), throwsA(isA<AppException>()));
    await store.transitionOrder(order.id, OrderStatus.preparing);
    await store.transitionOrder(order.id, OrderStatus.ready);
    await store.transitionOrder(order.id, OrderStatus.completed);
    await expectLater(store.cancelOrder(order.id), throwsA(isA<AppException>()));
    final restored = makeStore(disk); await restored.initialize();
    expect(restored.orders.single.status, OrderStatus.completed);
    expect(restored.orders.single.total, 23000);
    expect(restored.orders.single.paidAt, time);
    store.dispose(); restored.dispose();
  });
  test('failed payment retries while expired payment cannot be confirmed', () async {
    final store = makeStore(MemoryLocalStore()); await store.initialize(); await register(store);
    fillCheckout(store); final order = await store.checkout();
    await store.simulatePayment(order.id, success: false);
    expect(store.orderById(order.id).status, OrderStatus.failed);
    time = time.add(const Duration(minutes: 2));
    await store.retryPayment(order.id, paymentMethod: 'DANA');
    expect(store.orderById(order.id).paymentMethod, 'DANA');
    expect(store.orderById(order.id).expiresAt, time.add(const Duration(minutes: 10)));
    time = time.add(const Duration(minutes: 10));
    await store.refreshOrderExpiry();
    expect(store.orderById(order.id).status, OrderStatus.expired);
    await expectLater(store.simulatePayment(order.id, success: true), throwsA(isA<AppException>()));
    await expectLater(store.retryPayment(order.id), throwsA(isA<AppException>()));
    store.dispose();
  });
  test('pickup guards prevent full, past and under-20-minute slots', () async {
    final store = makeStore(MemoryLocalStore()); await store.initialize();
    expect(store.isPickupSlotAvailable('11.45–12.00', date: time), isFalse);
    expect(store.isPickupSlotAvailable('12.00–12.15', date: time), isTrue);
    time = DateTime(2026, 10, 21, 11, 41);
    expect(store.isPickupSlotAvailable('12.00–12.15', date: time), isFalse);
    expect(store.isPickupSlotAvailable('12.15–12.30', date: time), isTrue);
    store.setPickupSlot('12.00–12.15');
    store.setPickupDate(time); expect(store.pickupSlot, isNull);
    expect(() => store.setPickupDate(DateTime(2026, 10, 19)), throwsA(isA<AppException>()));
    store.dispose();
  });
  test('account carts and orders are isolated across logout/login', () async {
    final store = makeStore(MemoryLocalStore()); await store.initialize(); await register(store);
    fillCheckout(store); final order = await store.checkout();
    store.addToCart(store.foodById('geprek'), quantity: 2); await store.flush();
    await store.logout();
    expect(store.orders, isEmpty); expect(store.cartLines, isEmpty);
    await register(store, 'other@example.com');
    expect(store.orders, isEmpty); expect(store.cartLines, isEmpty);
    await expectLater(store.cancelOrder(order.id), throwsA(isA<AppException>()));
    await store.logout();
    await store.login(email: 'anjari@example.com', password: 'password123');
    expect(store.cartCount, 2); expect(store.orders.single.id, order.id);
    store.dispose();
  });
  test('password reset token is single-use, expires and never sent externally', () async {
    final store = makeStore(MemoryLocalStore()); await store.initialize(); await register(store);
    final token = await store.requestPasswordReset('anjari@example.com');
    await store.resetPassword(email: 'anjari@example.com', token: token,
      password: 'newpassword123', confirmPassword: 'newpassword123');
    expect(store.isLoggedIn, isFalse);
    await expectLater(store.resetPassword(email: 'anjari@example.com', token: token,
      password: 'anotherpass', confirmPassword: 'anotherpass'), throwsA(isA<AppException>()));
    await expectLater(store.login(email: 'anjari@example.com', password: 'password123'), throwsA(isA<AppException>()));
    await store.login(email: 'anjari@example.com', password: 'newpassword123');
    final expired = await store.requestPasswordReset('anjari@example.com');
    time = time.add(const Duration(minutes: 11));
    await expectLater(store.resetPassword(email: 'anjari@example.com', token: expired,
      password: 'anotherpass', confirmPassword: 'anotherpass'), throwsA(isA<AppException>()));
    store.dispose();
  });
  test('reset and security form reject reusing the previous password', () async {
    final store = makeStore(MemoryLocalStore()); await store.initialize(); await register(store);
    await expectLater(store.changePassword(currentPassword: 'password123',
      password: 'password123', confirmPassword: 'password123'), throwsA(isA<AppException>()));
    final token = await store.requestPasswordReset('anjari@example.com');
    await expectLater(store.resetPassword(email: 'anjari@example.com', token: token,
      password: 'password123', confirmPassword: 'password123'), throwsA(isA<AppException>()));
    await store.resetPassword(email: 'anjari@example.com', token: token,
      password: 'newpassword123', confirmPassword: 'newpassword123');
    await store.login(email: 'anjari@example.com', password: 'newpassword123');
    expect(store.isLoggedIn, isTrue); store.dispose();
  });
  test('failed storage rolls checkout back and retry creates exactly one order', () async {
    final disk = FailingStore(); final store = makeStore(disk);
    await store.initialize(); await register(store); fillCheckout(store); await store.flush();
    disk.fail = true;
    await expectLater(store.checkout(), throwsA(isA<AppException>()));
    expect(store.cartCount, 2); expect(store.orders, isEmpty);
    disk.fail = false;
    await store.checkout(); expect(store.orders, hasLength(1)); expect(store.cartCount, 0);
    store.dispose();
  });
  test('invalid saved document is retained and mutations are blocked', () async {
    final disk = MemoryLocalStore(); disk.values[AppStore.storageKey] = '{broken';
    final store = makeStore(disk); await store.initialize();
    expect(store.persistenceError, isNotNull);
    expect(disk.values[AppStore.storageKey], '{broken');
    await expectLater(register(store), throwsA(isA<AppException>()));
    store.dispose();
  });
  test('email edit preserves account id, rejects duplicates and invalidates reset token', () async {
    final store = makeStore(MemoryLocalStore()); await store.initialize(); await register(store);
    final id = store.user!.id;
    final token = await store.requestPasswordReset('anjari@example.com');
    await store.updateProfile(store.user!.copyWith(email: ' NEW@example.com '));
    expect(store.user!.id, id); expect(store.user!.email, 'new@example.com');
    await expectLater(store.resetPassword(email: 'new@example.com', token: token,
      password: 'anotherpass', confirmPassword: 'anotherpass'), throwsA(isA<AppException>()));
    await store.logout();
    await expectLater(store.login(email: 'anjari@example.com', password: 'password123'), throwsA(isA<AppException>()));
    await store.login(email: 'new@example.com', password: 'password123');
    expect(store.user!.id, id);
    await store.logout(); await register(store, 'second@example.com');
    await expectLater(store.updateProfile(store.user!.copyWith(email: 'new@example.com')), throwsA(isA<AppException>()));
    expect(store.user!.email, 'second@example.com'); store.dispose();
  });
  test('initialization can retry without overwriting unreadable stored data', () async {
    final disk = MemoryLocalStore(); final first = makeStore(disk);
    await first.initialize(); await register(first);
    final validDocument = disk.values[AppStore.storageKey]!;
    disk.values[AppStore.storageKey] = '{broken';
    final restored = makeStore(disk); await restored.initialize();
    expect(restored.initializationFailed, isTrue);
    disk.values[AppStore.storageKey] = validDocument;
    await restored.retryInitialization();
    expect(restored.initializationFailed, isFalse);
    expect(restored.user!.email, 'anjari@example.com');
    first.dispose(); restored.dispose();
  });
  test('theme, favorites and pickup preference survive process recreation', () async {
    final disk = MemoryLocalStore(); final store = makeStore(disk);
    await store.initialize(); await register(store);
    store.toggleFavorite('geprek'); store.toggleFavoriteCanteen('kantin_a');
    await store.setPreferredPickupSlot('12.30–12.45');
    await store.setThemeMode(ThemeMode.dark);
    final restored = makeStore(disk); await restored.initialize();
    expect(restored.favoriteIds, contains('geprek'));
    expect(restored.favoriteCanteenIds, contains('kantin_a'));
    expect(restored.preferredPickupSlot, '12.30–12.45');
    expect(restored.themeMode, AppStage.current >= 3 ? ThemeMode.dark : ThemeMode.light);
    store.dispose(); restored.dispose();
  });
}
