import 'package:flutter/material.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../order/presentation/widgets/order_widgets.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context) {
    final order = findOrder(context, orderId);
    return Scaffold(appBar: AppBar(title: const Text('Status pembayaran')), body: ListView(padding: const EdgeInsets.all(20), children: [
      const EmptyState(icon: Icons.schedule_outlined, title: 'Menunggu pembayaran', message: 'Pesanan belum mulai disiapkan.'),
      if (order != null) OrderSummary(order), const SizedBox(height: 20),
      const InfoBox('Preview UI — status ini bukan hasil konfirmasi payment gateway.'), const SizedBox(height: 24),
      AppButton(label: 'Periksa status pembayaran', onPressed: () => foundationNotice(context)),
    ]));
  }
}
