import '../../../../core/utils/formatters.dart';
import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../app/app_router.dart';
import '../../../../app/app_stage.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../models/kantin_order.dart';
import '../widgets/order_widgets.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool busy = false;
  Future<void> run(Future<void> Function() callback, {String? route}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await callback();
      if (mounted && route != null) await Navigator.pushNamed(context, route, arguments: widget.orderId);
    } catch (error) { if (mounted) showMessage(context, error.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> reorder() async {
    final store = AppScope.of(context);
    if (store.cartLines.isNotEmpty && !await confirmAction(context, title: 'Ganti isi keranjang?', message: 'Menu dari pesanan ini akan menggantikan keranjang yang ada.', confirmLabel: 'Ganti keranjang')) return;
    if (mounted) await run(() => store.reorder(widget.orderId), route: '/cart');
  }
  @override
  Widget build(BuildContext context) {
    final order = findOrder(context, widget.orderId);
    if (order == null) return Scaffold(appBar: AppBar(title: const Text('Detail pesanan')), body: const EmptyState(icon: Icons.receipt_long_outlined, title: 'Pesanan tidak ditemukan', message: 'Buka daftar pesanan dari akun yang sesuai.'));
    final store = AppScope.of(context);
    final canteen = store.canteenById(order.canteenId);
    final title = switch (order.status) {
      OrderStatus.pending => 'Menunggu pembayaran',
      OrderStatus.confirmed => 'Pembayaran diterima',
      OrderStatus.preparing => 'Pesanan sedang diproses',
      OrderStatus.ready => 'Pesanan siap diambil',
      OrderStatus.completed => 'Pesanan selesai',
      OrderStatus.cancelled => 'Pesanan dibatalkan',
      OrderStatus.failed => 'Pembayaran gagal',
      OrderStatus.expired => 'Pembayaran kedaluwarsa',
    };
    final subtitle = switch (order.status) {
      OrderStatus.pending => 'Bayar dulu agar pesanan dapat diproses.',
      OrderStatus.confirmed => 'Dibayar. Menunggu konfirmasi kantin.',
      OrderStatus.preparing => 'Dibayar. Pesanan sedang disiapkan.',
      OrderStatus.ready => 'Tunjukkan kode ini saat mengambil pesanan.',
      OrderStatus.completed => 'Terima kasih. Selamat menikmati!',
      _ => 'Pesanan ini tidak diproses oleh kantin. Belum ada pembayaran yang diterima.',
    };
    return Scaffold(appBar: AppBar(title: const Text('Detail pesanan')), body: ListView(padding: const EdgeInsets.all(20), children: [
      if (AppStage.current == 1) ...[const InfoBox('Preview UI — status dan pembayaran merupakan data contoh.'), const SizedBox(height: 16)],
      Row(children: [Expanded(child: Text('#${order.id}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700))), StatusBadge(order.status)]),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8), Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 16),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.schedule, size: 20), const SizedBox(width: 10), Expanded(child: Text('Waktu ambil\n${pickupLabel(order.pickupDate, order.pickupSlot)}'))]),
        const SizedBox(height: 14),
        Row(children: [const Icon(Icons.storefront_outlined, size: 20), const SizedBox(width: 10), Expanded(child: Text('${canteen.name}\n${canteen.location}', style: const TextStyle(fontSize: 13)))]),
      ])),
      const SizedBox(height: 12),
      if (order.pickupCode.isEmpty) InfoBox(order.canPay ? 'Kode pengambilan tersedia setelah pembayaran berhasil.' : 'Tidak ada kode pengambilan untuk pesanan ini.')
      else AppCard(onTap: () => Navigator.pushNamed(context, '/pickup-code', arguments: order.id), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(order.pickupCode, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 6), const Text('Kode pengambilan · tunjukkan saat siap', style: TextStyle(fontSize: 12)),
      ])),
      const SizedBox(height: 12),
      if (!order.status.isTerminal || order.status == OrderStatus.completed) ...[OrderTimeline(order.status), const SizedBox(height: 12)],
      OrderSummary(order), const SizedBox(height: 20),
      if (order.canPay) AppButton(label: 'Lanjut pembayaran', onPressed: () => Navigator.pushNamed(context, '/payment', arguments: order.id)),
      if (order.canCancel) TextButton(onPressed: busy ? null : () async {
        final confirmed = await confirmAction(context, title: 'Batalkan pesanan ini?', message: 'Pesanan #${order.id} belum dibayar. Jika dibatalkan, pesanan ini tidak akan diproses oleh kantin.', confirmLabel: 'Ya, batalkan pesanan');
        if (confirmed && mounted) await run(() => store.cancelOrder(order.id));
      }, child: Text('Batalkan pesanan', style: TextStyle(color: Theme.of(context).colorScheme.error))),
      if (order.pickupCode.isNotEmpty) AppButton(label: 'Lihat bukti pembayaran', onPressed: () => Navigator.pushNamed(context, '/receipt', arguments: order.id)),
      if (order.status == OrderStatus.failed) ...[
        const SizedBox(height: 8),
        AppButton(label: 'Coba bayar lagi', loading: busy, onPressed: () => run(() => store.retryPayment(order.id), route: '/payment')),
      ],
      if (order.status.isTerminal) ...[
        const SizedBox(height: 8), AppButton(label: 'Pesan lagi', outlined: true, loading: busy, onPressed: reorder),
      ],
      if ([OrderStatus.confirmed, OrderStatus.preparing, OrderStatus.ready].contains(order.status)) ...[
        const SizedBox(height: 20),
        const InfoBox('SIMULASI KANTIN — gunakan kontrol ini untuk menguji persiapan dan pengambilan pesanan. Status produksi nantinya diperbarui oleh petugas kantin.'),
        const SizedBox(height: 12),
        AppButton(label: switch (order.status) {
          OrderStatus.confirmed => 'Simulasikan mulai diproses',
          OrderStatus.preparing => 'Simulasikan siap diambil',
          _ => 'Simulasikan selesai diambil',
        }, outlined: true, loading: busy, onPressed: () => run(() => store.transitionOrder(order.id, switch (order.status) {
          OrderStatus.confirmed => OrderStatus.preparing,
          OrderStatus.preparing => OrderStatus.ready,
          _ => OrderStatus.completed,
        }))),
      ],
      const SizedBox(height: 8),
      AppButton(label: 'Kembali ke Order', outlined: true, onPressed: () => AppRouter.goTab(context, 1)),
    ]));
  }
}
