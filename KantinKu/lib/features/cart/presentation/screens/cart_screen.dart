import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../app/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../order/presentation/widgets/order_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  void mutate(BuildContext context, VoidCallback action) {
    try { action(); } catch (error) { showMessage(context, error.toString()); }
  }
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: store.cartLines.isEmpty
        ? EmptyState(icon: Icons.shopping_bag_outlined, title: 'Keranjang masih kosong', message: 'Pilih menu dari satu kantin untuk mulai memesan.', action: AppButton(label: 'Cari menu', onPressed: () => AppRouter.goTab(context, 2)))
        : ListView(padding: const EdgeInsets.all(20), children: [
          AppCard(child: Row(children: [const Icon(Icons.storefront_outlined), const SizedBox(width: 12), Expanded(child: Text(store.canteenById(store.cartLines.first.food.canteenId).name, style: Theme.of(context).textTheme.titleMedium))])),
          const SizedBox(height: 16),
          for (final line in store.cartLines) Padding(padding: const EdgeInsets.only(bottom: 14), child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FoodPhoto(line.food.image, width: 72, height: 72), const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(line.food.name, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), Text(rupiah(line.food.price), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
              ])),
              IconButton(tooltip: 'Hapus ${line.food.name}', onPressed: () => mutate(context, () => store.removeFromCart(line.food.id)), icon: const Icon(Icons.delete_outline, size: 20)),
            ]),
            const SizedBox(height: 12),
            Row(children: [Text(rupiah(line.total), style: const TextStyle(fontWeight: FontWeight.w700)), const Spacer(), QuantitySelector(value: line.quantity, min: 0, onChanged: (qty) => mutate(context, () => store.setQuantity(line.food.id, qty)))]),
            const SizedBox(height: 8),
            TextFormField(key: ValueKey('note-${line.food.id}'), initialValue: line.note, maxLength: 200, decoration: const InputDecoration(labelText: 'Catatan untuk kantin', hintText: 'Contoh: tidak terlalu pedas', counterText: ''), onChanged: (text) => mutate(context, () => store.setItemNote(line.food.id, text))),
          ]))),
          TextButton.icon(onPressed: () => Navigator.pushNamed(context, '/canteen', arguments: store.canteenById(store.cartLines.first.food.canteenId)), icon: const Icon(Icons.add), label: const Text('Tambah menu dari kantin ini')),
          const SizedBox(height: 16), PriceSummary(subtotal: store.subtotal, fee: store.serviceFee, total: store.total), const SizedBox(height: 16),
          const InfoBox('Semua menu dalam satu pesanan berasal dari kantin yang sama. Pesanan diambil langsung di kantin.'),
        ]),
      bottomNavigationBar: store.cartLines.isEmpty ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: AppButton(label: 'Lanjut checkout · ${rupiah(store.total)}', onPressed: () => Navigator.pushNamed(context, '/checkout')))),
    );
  }
}
