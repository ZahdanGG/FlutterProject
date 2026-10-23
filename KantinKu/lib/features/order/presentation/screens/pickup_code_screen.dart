import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/order_widgets.dart';

class PickupCodeScreen extends StatelessWidget {
  const PickupCodeScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context) {
    final order = findOrder(context, orderId);
    final store = AppScope.of(context);
    final c = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: const Text('Kode pengambilan')), body: order == null || order.pickupCode.isEmpty
      ? const EmptyState(icon: Icons.lock_outline, title: 'Kode belum tersedia', message: 'Selesaikan pembayaran untuk mendapatkan kode pengambilan.')
      : ListView(padding: const EdgeInsets.all(20), children: [
        const InfoBox('Tunjukkan kode kepada petugas hanya setelah status pesanan Siap diambil.'),
        const SizedBox(height: 16), Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(20)), child: Column(children: [
          Icon(Icons.shopping_bag_outlined, color: c.onPrimary, size: 40), const SizedBox(height: 12),
          Text('KODE PENGAMBILAN', style: TextStyle(color: c.onPrimary, fontSize: 11, letterSpacing: 1.5)), const SizedBox(height: 16),
          Text(order.pickupCode, textAlign: TextAlign.center, style: TextStyle(color: c.onPrimary, fontSize: 32, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
          Text('#${order.id} · ${store.user?.name ?? ''}', style: TextStyle(color: c.onPrimary, fontSize: 12)), const SizedBox(height: 20),
          Text('${store.canteenById(order.canteenId).name} · Loket A\n${order.pickupSlot}', textAlign: TextAlign.center, style: TextStyle(color: c.onPrimary, height: 1.8)),
        ])),
        const SizedBox(height: 24), Text('Cara mengambil', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 12),
        Text('1. Datang ke ${store.canteenById(order.canteenId).location}.\n2. Tunjukkan kode ${order.pickupCode} ke petugas.\n3. Periksa dan ambil ${order.items.fold<int>(0, (n, l) => n + l.quantity)} item pesananmu.', style: const TextStyle(height: 1.9)),
        const SizedBox(height: 20), const InfoBox('Kode pengambilan bukan QR pembayaran. Jangan gunakan kode ini untuk membayar.'), const SizedBox(height: 20),
        AppButton(label: 'Kembali ke pesanan', outlined: true, onPressed: () => Navigator.pop(context)),
      ]));
  }
}
