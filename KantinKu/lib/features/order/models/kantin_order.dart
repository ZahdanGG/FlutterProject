import '../../../shared/models/cart_line.dart';

enum OrderStatus { pending, confirmed, preparing, ready, completed, cancelled, failed, expired }

extension OrderStatusInfo on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'Menunggu pembayaran', OrderStatus.confirmed => 'Dibayar',
    OrderStatus.preparing => 'Diproses', OrderStatus.ready => 'Siap diambil',
    OrderStatus.completed => 'Selesai', OrderStatus.cancelled => 'Dibatalkan',
    OrderStatus.failed => 'Pembayaran gagal', OrderStatus.expired => 'Kedaluwarsa',
  };
  bool get isActive => const [OrderStatus.pending, OrderStatus.confirmed,
      OrderStatus.preparing, OrderStatus.ready].contains(this);
  bool get isTerminal => !isActive;
  bool canTransitionTo(OrderStatus next) => switch (this) {
    OrderStatus.pending => const [OrderStatus.confirmed, OrderStatus.cancelled,
      OrderStatus.failed, OrderStatus.expired].contains(next),
    OrderStatus.confirmed => next == OrderStatus.preparing,
    OrderStatus.preparing => next == OrderStatus.ready,
    OrderStatus.ready => next == OrderStatus.completed,
    _ => false,
  };
}

class KantinOrder {
  const KantinOrder({required this.id, required this.userId, required this.canteenId,
    required this.items, required this.createdAt, required this.pickupSlot,
    required this.paymentMethod, this.status = OrderStatus.pending, this.serviceFee = 0});
  final String id, userId, canteenId, pickupSlot, paymentMethod;
  final List<CartLine> items;
  final DateTime createdAt;
  final OrderStatus status;
  final int serviceFee;
  int get subtotal => items.fold(0, (sum, line) => sum + line.total);
  int get total => subtotal + serviceFee;
  bool get canCancel => status == OrderStatus.pending;
  bool get canPay => status == OrderStatus.pending;
  String get pickupCode => const [OrderStatus.confirmed, OrderStatus.preparing,
    OrderStatus.ready, OrderStatus.completed].contains(status) ? 'AMBIL-${id.replaceAll('KK-', '')}' : '';
  KantinOrder copyWith({OrderStatus? status}) => KantinOrder(id: id, userId: userId,
    canteenId: canteenId, items: items, createdAt: createdAt, pickupSlot: pickupSlot,
    paymentMethod: paymentMethod, status: status ?? this.status, serviceFee: serviceFee);
  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'canteenId': canteenId,
    'items': items.map((e) => e.toJson()).toList(), 'createdAt': createdAt.toIso8601String(),
    'pickupSlot': pickupSlot, 'paymentMethod': paymentMethod, 'status': status.name,
    'serviceFee': serviceFee};
  factory KantinOrder.fromJson(Map<String, dynamic> json) => KantinOrder(
    id: json['id'] as String, userId: json['userId'] as String, canteenId: json['canteenId'] as String,
    items: (json['items'] as List).map((e) => CartLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    createdAt: DateTime.parse(json['createdAt'] as String), pickupSlot: json['pickupSlot'] as String,
    paymentMethod: json['paymentMethod'] as String,
    status: OrderStatus.values.byName(json['status'] as String), serviceFee: json['serviceFee'] as int? ?? 0);
}
