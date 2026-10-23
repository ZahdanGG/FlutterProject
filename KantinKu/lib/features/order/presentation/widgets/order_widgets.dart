import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../models/kantin_order.dart';

KantinOrder? findOrder(BuildContext context, String id) {
  for (final order in AppScope.of(context).orders) {
    if (order.id == id) return order;
  }
  return null;
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final OrderStatus status;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final error = [OrderStatus.cancelled, OrderStatus.failed, OrderStatus.expired].contains(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: error ? c.errorContainer : c.secondaryContainer, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(fontSize: 11, color: error ? c.onErrorContainer : c.onSecondaryContainer)),
    );
  }
}

class PriceSummary extends StatelessWidget {
  const PriceSummary({super.key, required this.subtotal, required this.fee, required this.total});
  final int subtotal, fee, total;
  @override
  Widget build(BuildContext context) => AppCard(child: Column(children: [
    _row(context, 'Subtotal', rupiah(subtotal)),
    const SizedBox(height: 10),
    _row(context, 'Biaya layanan', rupiah(fee)),
    const Padding(padding: EdgeInsets.symmetric(vertical: 7), child: Divider()),
    _row(context, 'Total pembayaran', rupiah(total), strong: true),
  ]));
  Widget _row(BuildContext context, String label, String value, {bool strong = false}) => Row(children: [
    Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: strong ? FontWeight.w600 : FontWeight.normal))),
    Text(value, style: TextStyle(fontSize: strong ? 17 : 13, fontWeight: strong ? FontWeight.w700 : FontWeight.normal, color: strong ? Theme.of(context).colorScheme.primary : null)),
  ]);
}

class OrderSummary extends StatelessWidget {
  const OrderSummary(this.order, {super.key});
  final KantinOrder order;
  @override
  Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Ringkasan pesanan', style: Theme.of(context).textTheme.titleMedium),
    const SizedBox(height: 12),
    for (final line in order.items) Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text('${line.quantity}× ${line.food.name}', style: const TextStyle(fontSize: 13))), Text(rupiah(line.total), style: const TextStyle(fontSize: 13))]),
      if (line.note.isNotEmpty) Text(line.note, style: Theme.of(context).textTheme.bodySmall),
    ])),
    Row(children: [const Expanded(child: Text('Total')), Text(rupiah(order.total), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 18))]),
    const SizedBox(height: 6),
    Text(order.paymentMethod, style: Theme.of(context).textTheme.bodySmall),
  ]));
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline(this.status, {super.key});
  final OrderStatus status;
  static const steps = [OrderStatus.pending, OrderStatus.confirmed, OrderStatus.preparing, OrderStatus.ready, OrderStatus.completed];
  @override
  Widget build(BuildContext context) => AppCard(child: Column(children: [
    for (var i = 0; i < steps.length; i++) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Icon(i <= steps.indexOf(status) ? Icons.check_circle_outline : Icons.radio_button_unchecked, size: 19, color: i <= steps.indexOf(status) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
      const SizedBox(width: 10),
      Text(steps[i].label, style: TextStyle(fontSize: 13, fontWeight: status == steps[i] ? FontWeight.w600 : FontWeight.normal)),
    ])),
  ]));
}
