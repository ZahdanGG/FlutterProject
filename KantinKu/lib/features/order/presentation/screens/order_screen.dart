import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../app/app_router.dart';
import '../../../../app/app_stage.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../models/kantin_order.dart';
import '../widgets/order_widgets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool history = false;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    if (!store.isLoggedIn) return Scaffold(
      appBar: AppBar(title: const Text('Order'), centerTitle: true, automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 22),
        const EmptyState(icon: Icons.receipt_long_outlined, title: 'Lihat pesananmu di sini', message: 'Masuk untuk memesan, melihat status persiapan, dan mengambil makanan saat siap.'),
        const SizedBox(height: 14),
        AppButton(label: 'Masuk', onPressed: () => Navigator.pushNamed(context, '/login')),
        const SizedBox(height: 12),
        AppButton(label: 'Daftar', outlined: true, onPressed: () => Navigator.pushNamed(context, '/register-role')),
        const SizedBox(height: 16),
        const InfoBox('Kamu tetap bisa melihat menu di Home dan Browse sebagai tamu.'),
        if (AppStage.current == 1) ...[
          const SizedBox(height: 20),
          TextButton(onPressed: () => store.setPreviewMode(true), child: const Text('Tampilkan contoh pesanan (preview)')),
        ],
      ]),
    );
    final orders = store.orders.where((o) => history ? !o.status.isActive : o.status.isActive).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Order'), automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (history) ...[Text('Riwayat pesanan', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 16)],
        Wrap(spacing: 8, children: [
          ChoiceChip(label: const Text('Pesanan aktif'), selected: !history, onSelected: (_) => setState(() => history = false)),
          ChoiceChip(label: const Text('Riwayat'), selected: history, onSelected: (_) => setState(() => history = true)),
        ]),
        if (AppStage.current == 1 && store.previewMode) ...[const SizedBox(height: 16), const InfoBox('Preview UI — data contoh. Belum ada transaksi nyata.')],
        const SizedBox(height: 16),
        if (!store.isLoggedIn && AppStage.current > 1) EmptyState(
          icon: Icons.receipt_long_outlined, title: 'Masuk untuk melihat pesanan',
          message: 'Pesanan aktif dan riwayatmu tersimpan di akun KantinKu.',
          action: AppButton(label: 'Masuk', onPressed: () => Navigator.pushNamed(context, '/login')),
        ) else if (orders.isEmpty) EmptyState(
          icon: history ? Icons.history : Icons.receipt_long_outlined,
          title: history ? 'Belum ada riwayat pesanan' : 'Belum ada pesanan aktif',
          message: history ? 'Kamu belum memiliki pembelian sebelumnya. Pesanan yang selesai akan muncul di sini.' : 'Pilih menu favoritmu dan tentukan waktu ambil. Pesanan baru akan muncul di sini.',
          action: AppButton(label: history ? 'Jelajahi menu' : 'Cari menu', onPressed: () => AppRouter.goTab(context, 2)),
        ),
        for (final order in orders) Padding(padding: const EdgeInsets.only(bottom: 16), child: AppCard(
          onTap: () => Navigator.pushNamed(context, '/order-detail', arguments: order.id),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text('#${order.id}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700))), StatusBadge(order.status)]),
            const SizedBox(height: 12),
            Text(store.canteenById(order.canteenId).name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(order.items.map((l) => '${l.food.name} ×${l.quantity}').join(' + '), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text('${order.pickupSlot} · ${rupiah(order.total)}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            AppButton(label: 'Detail pesanan', outlined: true, onPressed: () => Navigator.pushNamed(context, '/order-detail', arguments: order.id)),
            if (order.pickupCode.isNotEmpty) TextButton(onPressed: () => Navigator.pushNamed(context, '/receipt', arguments: order.id), child: const Text('Lihat bukti pembayaran')),
          ]),
        )),
        if (AppStage.current == 1) TextButton(onPressed: () => store.setPreviewMode(!store.previewMode), child: Text(store.previewMode ? 'Kembali ke tampilan tamu' : 'Tampilkan contoh pesanan (preview)')),
      ]),
    );
  }
}
