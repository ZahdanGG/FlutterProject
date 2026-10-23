import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../order/presentation/widgets/order_widgets.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context) {
    final order = findOrder(context, orderId);
    final qris = order?.paymentMethod == 'QRIS';
    return Scaffold(appBar: AppBar(title: Text(qris ? 'Pembayaran QRIS' : 'Konfirmasi e-wallet')), body: ListView(padding: const EdgeInsets.all(20), children: [
      const InfoBox('Preview pembayaran — tidak ada uang yang diterima atau dipindahkan.'), const SizedBox(height: 24),
      const Text('Menunggu pembayaran'), const SizedBox(height: 18), Text(order?.paymentMethod ?? 'QRIS', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 16),
      const Text('Total pembayaran'), const SizedBox(height: 8), Text(rupiah(order?.total ?? 0), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 24),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(qris ? Icons.qr_code_2 : Icons.account_balance_wallet_outlined, size: 48, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 16),
        Text(qris ? 'QRIS DEMO' : 'Konfirmasi di aplikasi e-wallet', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 12), const Text('Tidak tersedia kode pembayaran sungguhan. Ini hanya preview antarmuka pembayaran.'),
      ])), const SizedBox(height: 24),
      AppButton(label: 'Cek status pembayaran', onPressed: () => foundationNotice(context)),
      TextButton(onPressed: () => Navigator.pushNamed(context, '/payment-method'), child: const Text('Ganti metode pembayaran')),
    ]));
  }
}
