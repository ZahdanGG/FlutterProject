import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../order/presentation/widgets/order_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool submitting = false;
  Future<void> pay() async {
    final store = AppScope.of(context);
    if (!store.isLoggedIn) {
      await Navigator.pushNamed(context, '/login');
      return;
    }
    if (submitting) return;
    setState(() => submitting = true);
    try {
      final order = await store.checkout();
      if (mounted) await Navigator.pushReplacementNamed(context, '/payment', arguments: order.id);
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    if (store.cartLines.isEmpty) return Scaffold(appBar: AppBar(title: const Text('Checkout')), body: EmptyState(icon: Icons.shopping_bag_outlined, title: 'Keranjang masih kosong', message: 'Tambahkan menu sebelum melanjutkan checkout.', action: AppButton(label: 'Kembali', onPressed: () => Navigator.pop(context))));
    final canteen = store.canteenById(store.cartLines.first.food.canteenId);
    final complete = store.pickupSlot != null && store.paymentMethod != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.storefront_outlined, size: 21), const SizedBox(width: 10), Expanded(child: Text(canteen.name, style: Theme.of(context).textTheme.titleMedium))]),
          const SizedBox(height: 8), Text(canteen.location, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 8), Text('Buka ${canteen.openingHours} · Persiapan ${canteen.prepTime}', style: Theme.of(context).textTheme.bodySmall),
        ])),
        const SizedBox(height: 18), const SectionHeading('Ringkasan pesanan'), const SizedBox(height: 10),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final line in store.cartLines) Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(line.food.name, style: const TextStyle(fontWeight: FontWeight.w600))), Text('${line.quantity}')]),
            if (line.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(line.note, style: Theme.of(context).textTheme.bodySmall)),
          ])),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/cart'), child: const Text('Ubah keranjang')),
        ])),
        const SizedBox(height: 18), const SectionHeading('Waktu pengambilan'), const SizedBox(height: 6),
        Text('${store.pickupDate.day}/${store.pickupDate.month}/${store.pickupDate.year}', style: const TextStyle(fontSize: 12)), const SizedBox(height: 10),
        _ChoiceRow(label: store.pickupSlot == null ? 'Pilih waktu ambil' : pickupLabel(store.pickupDate, store.pickupSlot!), icon: Icons.schedule, route: '/pickup-time'),
        const SizedBox(height: 18), const SectionHeading('Metode pembayaran'), const SizedBox(height: 6),
        const Text('Pilih QRIS atau e-wallet', style: TextStyle(fontSize: 12)), const SizedBox(height: 10),
        _ChoiceRow(label: store.paymentMethod ?? 'Pilih metode pembayaran', icon: Icons.account_balance_wallet_outlined, route: '/payment-method'),
        const SizedBox(height: 18), PriceSummary(subtotal: store.subtotal, fee: store.serviceFee, total: store.total), const SizedBox(height: 14),
        const InfoBox('DEMO — tidak ada uang sungguhan yang dipindahkan. Status lunas hanya hasil simulasi.', icon: Icons.verified_user_outlined),
      ]),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: AppButton(label: complete ? 'Bayar ${rupiah(store.total)}' : 'Pilih waktu dan pembayaran', loading: submitting, onPressed: complete ? pay : null))),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.label, required this.icon, required this.route});
  final String label, route;
  final IconData icon;
  @override
  Widget build(BuildContext context) => AppCard(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), onTap: () => Navigator.pushNamed(context, route), child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 12), Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(label, style: const TextStyle(fontSize: 13)))), const Icon(Icons.chevron_right, size: 20)]));
}
