import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/format.dart';
import '../data/catalog.dart';

enum PaymentMethod { qris, saldo, cod }

extension PaymentMethodInfo on PaymentMethod {
  String get title {
    switch (this) {
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.saldo:
        return 'Saldo';
      case PaymentMethod.cod:
        return 'COD';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.qris:
        return 'Bayar dengan aplikasi QRIS';
      case PaymentMethod.saldo:
        return rupiah(AppState.saldoBalance);
      case PaymentMethod.cod:
        return 'Bayar saat pesanan tiba';
    }
  }
}

class CartLine {
  CartLine(this.item, this.qty);
  final MenuItem item;
  int qty;
  int get total => item.price * qty;
}

/// App-wide state: cart, favorites, payment method, order note.
/// Persisted with shared_preferences so a refresh/restart keeps the state.
class AppState extends ChangeNotifier {
  AppState._(this._prefs, this._cart, this._favorites, this._payment, this._note);

  static const saldoBalance = 125000;
  static const deliveryFee = 5000;
  static const serviceFee = 2000;
  static const voucherDiscount = 5000;

  static const _kCart = 'cart';
  static const _kFav = 'favorites';
  static const _kPay = 'payment';
  static const _kNote = 'note';

  final SharedPreferences _prefs;
  final List<CartLine> _cart;
  final Set<String> _favorites;
  PaymentMethod _payment;
  String _note;

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Cart: first launch starts with the cart shown in the Figma Order frame.
    List<CartLine> cart;
    final rawCart = prefs.getString(_kCart);
    if (rawCart == null) {
      cart = [
        CartLine(kAllItems['nasi-ayam-geprek']!, 1),
        CartLine(kEsTehManis, 1),
        CartLine(kMieAyamSpecial, 2),
      ];
    } else {
      cart = [];
      for (final m in (jsonDecode(rawCart) as List)) {
        final item = kAllItems[m['id']];
        if (item != null) cart.add(CartLine(item, m['qty'] as int));
      }
    }

    final favs = (prefs.getStringList(_kFav) ?? <String>[]).toSet();

    final payIndex = prefs.getInt(_kPay);
    final payment = (payIndex != null && payIndex < PaymentMethod.values.length)
        ? PaymentMethod.values[payIndex]
        : PaymentMethod.qris;

    // Figma shows this text in the note field on Checkout.
    final note = prefs.getString(_kNote) ?? 'Jangan terlalu pedas';

    return AppState._(prefs, cart, favs, payment, note);
  }

  // ---- cart ---------------------------------------------------------------

  List<CartLine> get cart => List.unmodifiable(_cart);
  int get itemCount => _cart.fold(0, (s, l) => s + l.qty);

  /// Cart lines grouped by warung, in insertion order.
  Map<String, List<CartLine>> get cartByWarung {
    final out = <String, List<CartLine>>{};
    for (final l in _cart) {
      out.putIfAbsent(l.item.warung ?? '', () => []).add(l);
    }
    return out;
  }

  int get subtotal => _cart.fold(0, (s, l) => s + l.total);
  int get delivery => _cart.isEmpty ? 0 : deliveryFee;
  int get service => _cart.isEmpty ? 0 : serviceFee;
  int get discount =>
      _cart.isEmpty ? 0 : (voucherDiscount > subtotal ? subtotal : voucherDiscount);
  int get total => subtotal + delivery + service - discount;

  void add(MenuItem item) {
    final i = _cart.indexWhere((l) => l.item.id == item.id);
    if (i >= 0) {
      _cart[i].qty++;
    } else {
      _cart.add(CartLine(item, 1));
    }
    _saveCart();
  }

  void changeQty(String id, int delta) {
    final i = _cart.indexWhere((l) => l.item.id == id);
    if (i < 0) return;
    final next = _cart[i].qty + delta;
    if (next < 1) return; // the trash button removes an item
    _cart[i].qty = next;
    _saveCart();
  }

  void remove(String id) {
    _cart.removeWhere((l) => l.item.id == id);
    _saveCart();
  }

  void _saveCart() {
    _prefs.setString(
      _kCart,
      jsonEncode([
        for (final l in _cart) {'id': l.item.id, 'qty': l.qty}
      ]),
    );
    notifyListeners();
  }

  // ---- favorites ----------------------------------------------------------

  bool isFavorite(String id) => _favorites.contains(id);

  void toggleFavorite(String id) {
    if (!_favorites.remove(id)) _favorites.add(id);
    _prefs.setStringList(_kFav, _favorites.toList());
    notifyListeners();
  }

  // ---- checkout -----------------------------------------------------------

  PaymentMethod get payment => _payment;

  void selectPayment(PaymentMethod m) {
    _payment = m;
    _prefs.setInt(_kPay, m.index);
    notifyListeners();
  }

  String get note => _note;

  void setNote(String v) {
    _note = v;
    _prefs.setString(_kNote, v);
    notifyListeners();
  }
}
