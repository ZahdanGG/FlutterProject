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
    OrderStatus.failed => next == OrderStatus.pending,
    _ => false,
  };
}

class KantinOrder {
  const KantinOrder({required this.id, required this.userId, required this.canteenId,
    required this.items, required this.createdAt, required this.pickupSlot,
    required this.paymentMethod, this.status = OrderStatus.pending, this.serviceFee = 0,
    this.pickupDate, this.paymentStartedAt, this.paidAt});
  final String id, userId, canteenId, pickupSlot, paymentMethod;
  final List<CartLine> items;
  final DateTime createdAt;
  final DateTime? pickupDate, paymentStartedAt, paidAt;
  final OrderStatus status;
  final int serviceFee;
  int get subtotal => items.fold(0, (sum, line) => sum + line.total);
  int get total => subtotal + serviceFee;
  bool get canCancel => status == OrderStatus.pending;
  bool get canPay => status == OrderStatus.pending;
  bool get isPaid => const [OrderStatus.confirmed, OrderStatus.preparing,
    OrderStatus.ready, OrderStatus.completed].contains(status);
  DateTime get expiresAt => (paymentStartedAt ?? createdAt).add(const Duration(minutes: 10));
  String get pickupCode => isPaid ? id : '';
  KantinOrder copyWith({OrderStatus? status, String? paymentMethod,
    DateTime? paymentStartedAt, DateTime? paidAt}) => KantinOrder(id: id, userId: userId,
    canteenId: canteenId, items: items, createdAt: createdAt, pickupSlot: pickupSlot,
    pickupDate: pickupDate, paymentMethod: paymentMethod ?? this.paymentMethod,
    status: status ?? this.status, serviceFee: serviceFee,
    paymentStartedAt: paymentStartedAt ?? this.paymentStartedAt,
    paidAt: paidAt ?? this.paidAt);
  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'canteenId': canteenId,
    'items': items.map((e) => e.toJson()).toList(), 'createdAt': createdAt.toIso8601String(),
    'pickupSlot': pickupSlot, 'pickupDate': pickupDate?.toIso8601String(),
    'paymentMethod': paymentMethod, 'status': status.name, 'serviceFee': serviceFee,
    'paymentStartedAt': paymentStartedAt?.toIso8601String(), 'paidAt': paidAt?.toIso8601String()};
  factory KantinOrder.fromJson(Map<String, dynamic> json) => KantinOrder(
    id: json['id'] as String, userId: json['userId'] as String, canteenId: json['canteenId'] as String,
    items: List.unmodifiable((json['items'] as List).map((e) => CartLine.fromJson(Map<String, dynamic>.from(e as Map)))),
    createdAt: DateTime.parse(json['createdAt'] as String), pickupSlot: json['pickupSlot'] as String,
    pickupDate: json['pickupDate'] == null ? null : DateTime.parse(json['pickupDate'] as String),
    paymentMethod: json['paymentMethod'] as String,
    paidAt: json['paidAt'] == null ? null : DateTime.parse(json['paidAt'] as String),
    paymentStartedAt: json['paymentStartedAt'] == null ? null : DateTime.parse(json['paymentStartedAt'] as String),
    status: OrderStatus.values.byName(json['status'] as String), serviceFee: json['serviceFee'] as int? ?? 0);
}
