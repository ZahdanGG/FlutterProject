import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../app/app_stage.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/order_widgets.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context) {
    final order = findOrder(context, orderId);
    return Scaffold(appBar: AppBar(title: const Text('Bukti pembayaran')), body: order == null || order.pickupCode.isEmpty
      ? const EmptyState(icon: Icons.receipt_long_outlined, title: 'Bukti belum tersedia', message: 'Bukti pembayaran tersedia setelah pembayaran diterima.')
      : ListView(padding: const EdgeInsets.all(20), children: [
        const InfoBox('BUKTI DEMO — pembayaran simulasi lokal, bukan transaksi keuangan sungguhan.'), const SizedBox(height: 16),
        Align(alignment: Alignment.centerLeft, child: Chip(label: Text(AppStage.current == 1 ? 'Contoh lunas' : 'Lunas'))),
        const SizedBox(height: 20), Text('#${order.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 16), Text(AppScope.of(context).canteenById(order.canteenId).name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        for (final line in order.items) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('${line.quantity}× ${line.food.name} · ${rupiah(line.total)}')),
        const SizedBox(height: 16), AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total pembayaran'), const SizedBox(height: 10), Text(rupiah(order.total), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 12), Text(order.paymentMethod),
        ])),
        const SizedBox(height: 16), Text('${order.paidAt == null ? 'Pesanan dibuat' : 'Dibayar (demo)'} ${dateTimeLabel(order.paidAt ?? order.createdAt)} · REF-${order.id}', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24), AppButton(label: 'Kembali ke riwayat', outlined: true, onPressed: () => Navigator.pushReplacementNamed(context, '/order-history')),
      ]));
  }
}
