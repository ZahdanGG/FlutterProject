import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/services/app_store.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../order/models/kantin_order.dart';
import '../../../order/presentation/widgets/order_widgets.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.orderId});
  final String orderId;
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool busy = false;
  Timer? timer;
  AppStore? store;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = AppScope.of(context);
    timer ??= Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted || busy) return;
      try { await store!.refreshOrderExpiry(); } catch (_) { /* Mutations report errors on user action. */ }
      if (mounted) setState(() {});
    });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  Future<void> run(Future<void> Function() action, {bool showStatus = false}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
      if (mounted && showStatus) await Navigator.pushReplacementNamed(context, '/payment-status', arguments: widget.orderId);
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> simulate() async {
    final result = await showModalBottomSheet<String>(context: context, showDragHandle: true, isScrollControlled: true, builder: (sheetContext) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Simulasi pembayaran', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12),
      const Text('Mode DEMO. Pilihan ini hanya mengubah status lokal; tidak membuka e-wallet atau memindahkan uang.'), const SizedBox(height: 24),
      AppButton(label: 'Simulasikan berhasil', onPressed: () => Navigator.pop(sheetContext, 'success')), const SizedBox(height: 10),
      AppButton(label: 'Simulasikan gagal', outlined: true, onPressed: () => Navigator.pop(sheetContext, 'failed')), const SizedBox(height: 8),
      AppButton(label: 'Tetap menunggu', outlined: true, onPressed: () => Navigator.pop(sheetContext)),
    ]))));
    if (result != null && mounted) await run(() => store!.simulatePayment(widget.orderId, success: result == 'success'), showStatus: true);
  }

  Future<void> changeMethod() async {
    final method = await showModalBottomSheet<String>(context: context, showDragHandle: true, builder: (sheetContext) => SafeArea(child: ListView(shrinkWrap: true, children: [
      const ListTile(title: Text('Ganti metode pembayaran', style: TextStyle(fontWeight: FontWeight.w700))),
      for (final value in ['QRIS', 'GoPay', 'OVO', 'DANA', 'ShopeePay']) ListTile(leading: Icon(value == 'QRIS' ? Icons.qr_code : Icons.account_balance_wallet_outlined), title: Text(value), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pop(sheetContext, value)),
    ])));
    if (method != null && mounted) await run(() => store!.retryPayment(widget.orderId, paymentMethod: method));
  }

  @override
  Widget build(BuildContext context) {
    final order = findOrder(context, widget.orderId);
    if (order == null) return Scaffold(appBar: AppBar(title: const Text('Pembayaran')), body: const EmptyState(icon: Icons.receipt_long_outlined, title: 'Pesanan tidak ditemukan', message: 'Masuk dengan akun pemesan untuk melihat pembayaran.'));
    final qris = order.paymentMethod == 'QRIS';
    final remaining = order.expiresAt.difference(store!.currentTime);
    final expired = remaining.isNegative || order.status == OrderStatus.expired;
    final canSimulate = order.status == OrderStatus.pending && !expired;
    return Scaffold(appBar: AppBar(title: Text(qris ? 'Pembayaran QRIS' : 'Konfirmasi e-wallet')), body: ListView(padding: const EdgeInsets.all(20), children: [
      const InfoBox('DEMO — tidak ada uang yang diterima atau dipindahkan.'), const SizedBox(height: 18),
      Text(order.status.label, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 18),
      if (!qris) ...[Text(order.paymentMethod, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 16)],
      const Text('Total pembayaran'), const SizedBox(height: 8), Text(rupiah(order.total), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 8),
      if (order.status == OrderStatus.pending) Text(expired ? 'Batas pembayaran telah berakhir' : 'Sisa waktu ${(remaining.inSeconds / 60).ceil()} menit', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 24),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(qris ? 'QRIS' : 'Konfirmasi di aplikasi e-wallet', style: Theme.of(context).textTheme.titleMedium)), const Chip(label: Text('DEMO'))]), const SizedBox(height: 20),
        if (qris) Center(child: Column(children: [Icon(Icons.qr_code_2, size: 112, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 10), const Text('Ilustrasi QR — tidak dapat dipakai membayar', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))])),
        const SizedBox(height: 20), Text(store!.canteenById(order.canteenId).name), const SizedBox(height: 8), Text('Pesanan #${order.id}', style: Theme.of(context).textTheme.bodySmall),
        if (!qris) ...[const SizedBox(height: 14), Text('Nominal ${rupiah(order.total)}. Gunakan simulasi di bawah untuk mencoba pembayaran ${order.paymentMethod}.')],
      ])), const SizedBox(height: 24),
      Text('Cara membayar', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 10), const Text('Pada aplikasi demo ini, pilih hasil simulasi pembayaran. Tidak ada koneksi ke QRIS atau aplikasi e-wallet.'), const SizedBox(height: 20),
      if (canSimulate) AppButton(label: qris ? 'Buka simulasi pembayaran' : 'Simulasikan ${order.paymentMethod}', loading: busy, onPressed: simulate),
      const SizedBox(height: 10), AppButton(label: 'Cek status pembayaran', outlined: true, loading: busy, onPressed: () => run(() => store!.refreshOrderExpiry(), showStatus: true)),
      if (canSimulate || order.status == OrderStatus.failed) TextButton(onPressed: busy ? null : changeMethod, child: const Text('Ganti metode pembayaran')),
    ]));
  }
}
