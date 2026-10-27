import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kantinku/app/app.dart';
import 'package:kantinku/app/app_shell.dart';
import 'package:kantinku/core/services/app_store.dart';
import 'package:kantinku/core/services/local_store.dart';
import 'package:kantinku/features/auth/data/auth_repository.dart';
import 'package:kantinku/features/home/presentation/screens/home_screen.dart';
import 'package:kantinku/features/order/models/kantin_order.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('register, choose food, checkout, simulate payment, restore history', (tester) async {
    // Isolated test storage prevents changing a developer's demo account.
    final disk = MemoryLocalStore();
    final store = AppStore(persistence: disk,
      authRepository: AuthRepository(iterations: 1000),
      clock: () => DateTime(2030, 1, 10, 10));
    await store.initialize();
    AppShell.selectedTab.value = 0;
    await tester.pumpWidget(KantinKuApp(store: store));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(HomeScreen))).pushNamed('/register', arguments: 'Mahasiswa');
    await tester.pumpAndSettle();
    for (final entry in const {
      'Nama lengkap': 'Nadia Putri', 'Email': 'nadia@example.com', 'Nomor HP': '081234567890',
      'Password': 'ContohAman123', 'Konfirmasi password': 'ContohAman123',
      'Kampus': 'Universitas Contoh', 'Program studi': 'Informatika',
    }.entries) {
      final field = find.byKey(ValueKey('field-${entry.key}'));
      await tester.ensureVisible(field);
      await tester.enterText(field, entry.value);
    }
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Buat akun').last);
    await tester.tap(find.text('Buat akun').last);
    await tester.pumpAndSettle();
    expect(store.isLoggedIn, isTrue);
    await tester.tap(find.text('Lanjut ke menu sebelumnya'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(HomeScreen))).pushNamed('/menu', arguments: store.foodById('geprek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah ke keranjang'));
    await tester.pumpAndSettle();
    expect(store.cartCount, 1);
    // Slot/method use the same controller as their picker screens; payment and
    // order transitions are explicitly demo operations, never external money.
    store.setPickupDate(DateTime(2030, 1, 10));
    store.setPickupSlot('12.00–12.15');
    store.setPaymentMethod('QRIS');
    final order = await store.checkout();
    expect(order.status, OrderStatus.pending);
    expect(order.pickupCode, isEmpty);
    await store.simulatePayment(order.id, success: true);
    await store.transitionOrder(order.id, OrderStatus.preparing);
    await store.transitionOrder(order.id, OrderStatus.ready);
    await store.transitionOrder(order.id, OrderStatus.completed);
    await store.flush();
    final restored = AppStore(persistence: disk, clock: () => DateTime(2030, 1, 10, 10));
    await restored.initialize();
    expect(restored.orders.single.status, OrderStatus.completed);
    expect(restored.orders.single.total, 18000);
    expect(restored.isLoggedIn, isTrue);
    expect(restored.cartCount, 0);
    restored.dispose();
    await tester.pumpWidget(const SizedBox());
    store.dispose();
  });
}
