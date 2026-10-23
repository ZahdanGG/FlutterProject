import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Metode pembayaran')), body: ListView(padding: const EdgeInsets.all(20), children: [
    Text('Bayar dengan nyaman', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 12), const Text('Pilih QRIS atau dompet digital.'), const SizedBox(height: 24),
    PaymentOption(icon: Icons.qr_code, title: 'QRIS', subtitle: 'Pindai lewat aplikasi pembayaran', onTap: () { AppScope.of(context).setPaymentMethod('QRIS'); Navigator.pop(context); }),
    const SizedBox(height: 12),
    PaymentOption(icon: Icons.account_balance_wallet_outlined, title: 'Dompet digital', subtitle: 'GoPay, OVO, DANA, ShopeePay', onTap: () async { final selected = await Navigator.pushNamed(context, '/wallet'); if (selected == true && context.mounted) Navigator.pop(context); }),
  ]));
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Dompet digital')), body: ListView(padding: const EdgeInsets.all(20), children: [
    Text('Pilih e-wallet', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 24),
    for (final wallet in ['GoPay', 'OVO', 'DANA', 'ShopeePay']) Padding(padding: const EdgeInsets.only(bottom: 14), child: PaymentOption(icon: Icons.account_balance_wallet_outlined, title: wallet, subtitle: 'Konfirmasi di aplikasi $wallet', onTap: () { AppScope.of(context).setPaymentMethod(wallet); Navigator.pop(context, true); })),
  ]));
}

class PaymentOption extends StatelessWidget {
  const PaymentOption({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AppCard(onTap: onTap, child: Row(children: [
    Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 5), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)])),
    const Icon(Icons.chevron_right, size: 20),
  ]));
}
