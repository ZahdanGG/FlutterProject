import 'package:flutter_test/flutter_test.dart';
import 'package:KantinKu/core/services/app_store.dart';
import 'package:KantinKu/features/order/models/kantin_order.dart';

void main() {
  test('quantity and totals share one source and remove at zero', () {
    final store = AppStore();
    store.addToCart(store.foodById('geprek'), quantity: 2);
    store.addToCart(store.foodById('es_teh'));
    expect(store.subtotal, 41000);
    expect(store.total, 41000);
    expect(store.cartCount, 3);
    store.setQuantity('geprek', 1);
    expect(store.total, 23000);
    store.setQuantity('es_teh', 0);
    expect(store.total, 18000);
    store.dispose();
  });
  test('invalid quantities, sold-out food and mixed canteens are rejected', () {
    final store = AppStore();
    expect(() => store.addToCart(store.foodById('geprek'), quantity: 0), throwsRangeError);
    expect(() => store.addToCart(store.foodById('kopi_susu')), throwsStateError);
    store.addToCart(store.foodById('geprek'), quantity: 99);
    expect(() => store.addToCart(store.foodById('geprek')), throwsRangeError);
    expect(() => store.addToCart(store.foodById('mie_ayam')), throwsStateError);
    expect(store.cartCount, 99);
    store.dispose();
  });
  test('order lifecycle disallows skipped and terminal transitions', () {
    expect(OrderStatus.pending.canTransitionTo(OrderStatus.confirmed), isTrue);
    expect(OrderStatus.pending.canTransitionTo(OrderStatus.completed), isFalse);
    expect(OrderStatus.confirmed.canTransitionTo(OrderStatus.cancelled), isFalse);
    expect(OrderStatus.preparing.canTransitionTo(OrderStatus.ready), isTrue);
    expect(OrderStatus.ready.canTransitionTo(OrderStatus.completed), isTrue);
    expect(OrderStatus.completed.canTransitionTo(OrderStatus.pending), isFalse);
  });
  test('foundation preview remains explicit and guest has no synthetic orders', () {
    final store = AppStore();
    expect(store.user, isNull);
    expect(store.orders, isEmpty);
    store.setPreviewMode(true);
    expect(store.previewMode, isTrue);
    expect(store.user!.id, 'preview');
    expect(store.orders.single.total, 23000);
    store.setPreviewMode(false);
    expect(store.orders, isEmpty);
    store.dispose();
  });
}
