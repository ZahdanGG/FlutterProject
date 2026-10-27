import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../app/app_router.dart';
import '../../../../core/services/app_store.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../order/models/kantin_order.dart';
import '../../../order/presentation/widgets/order_widgets.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key, required this.orderId});
  final String orderId;
  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  bool busy = false;
  Timer? timer;
  AppStore? store;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = AppScope.of(context);
    timer ??= Timer.periodic(const Duration(seconds: 15), (_) async {
      if (mounted && !busy) {
        try { await store!.refreshOrderExpiry(); } catch (_) { /* Retry remains available. */ }
      }
    });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  Future<void> action(Future<void> Function() callback, {String? route}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await callback();
      if (mounted && route != null) await Navigator.pushReplacementNamed(context, route, arguments: widget.orderId);
    } catch (error) { if (mounted) showMessage(context, error.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> newOrder() async {
    if (store!.cartLines.isNotEmpty && !await confirmAction(context, title: 'Ganti isi keranjang?', message: 'Menu pada pesanan ini akan menggantikan keranjang yang ada.', confirmLabel: 'Ganti keranjang')) return;
    if (!mounted) return;
    await action(() => store!.reorder(widget.orderId), route: '/cart');
  }
  @override
  Widget build(BuildContext context) {
    final order = findOrder(context, widget.orderId);
    if (order == null) return Scaffold(appBar: AppBar(title: const Text('Status pembayaran')), body: const EmptyState(icon: Icons.receipt_long_outlined, title: 'Pesanan tidak ditemukan', message: 'Buka pesanan dari akun yang sesuai.'));
    final paid = order.pickupCode.isNotEmpty;
    final expired = order.status == OrderStatus.expired;
    final failed = order.status == OrderStatus.failed;
    final cancelled = order.status == OrderStatus.cancelled;
    final title = paid ? 'Pembayaran berhasil' : expired ? 'Pembayaran kedaluwarsa' : failed ? 'Pembayaran gagal' : cancelled ? 'Pesanan dibatalkan' : 'Menunggu pembayaran';
    final message = paid ? 'Pembayaran demo telah diterima. Pesanan dapat dilanjutkan ke proses persiapan.' : expired ? 'Batas pembayaran telah lewat. Pesanan belum dibayar dan tidak diteruskan ke kantin.' : failed ? 'Pembayaran belum berhasil. Kamu dapat mencoba lagi atau memilih metode lain.' : cancelled ? 'Pesanan tidak diproses oleh kantin. Tidak ada pembayaran yang diterima.' : 'Konfirmasi pembayaran ${rupiah(order.total)} melalui simulasi. Pesanan belum mulai disiapkan.';
    return Scaffold(appBar: AppBar(title: const Text('Status pembayaran')), body: ListView(padding: const EdgeInsets.all(20), children: [
      EmptyState(icon: paid ? Icons.check_circle_outline : failed ? Icons.cancel_outlined : expired ? Icons.timer_off_outlined : Icons.schedule_outlined, title: title, message: message),
      AppCard(child: Column(children: [
        _row('Kantin', store!.canteenById(order.canteenId).name), _row('Kode pesanan', '#${order.id}'), _row('Metode', order.paymentMethod), const Divider(), _row('Total pembayaran', rupiah(order.total)), _row('Waktu ambil', pickupLabel(order.pickupDate, order.pickupSlot)),
      ])), const SizedBox(height: 18),
      const InfoBox('DEMO — status pembayaran berasal dari simulasi lokal, bukan konfirmasi payment gateway.'), const SizedBox(height: 24),
      if (paid) AppButton(label: 'Lihat pesanan', onPressed: () => Navigator.pushReplacementNamed(context, '/order-detail', arguments: order.id))
      else if (expired || cancelled) AppButton(label: 'Buat pesanan baru', loading: busy, onPressed: newOrder)
      else if (failed) ...[
        AppButton(label: 'Coba bayar lagi', loading: busy, onPressed: () => action(() => store!.retryPayment(order.id), route: '/payment')),
        TextButton(onPressed: busy ? null : () => Navigator.pushReplacementNamed(context, '/payment', arguments: order.id), child: const Text('Ganti metode pembayaran')),
      ] else ...[
        AppButton(label: 'Periksa status pembayaran', loading: busy, onPressed: () => action(() => store!.refreshOrderExpiry())),
        AppButton(label: 'Lanjut pembayaran demo', outlined: true, onPressed: () => Navigator.pushReplacementNamed(context, '/payment', arguments: order.id)),
      ],
      const SizedBox(height: 10), TextButton(onPressed: () => AppRouter.goTab(context, 1), child: const Text('Kembali ke Order')),
    ]));
  }
  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 12))), Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))]));
}
