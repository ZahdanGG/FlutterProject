import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';

class PickupTimeScreen extends StatefulWidget {
  const PickupTimeScreen({super.key});
  @override
  State<PickupTimeScreen> createState() => _PickupTimeScreenState();
}

class _PickupTimeScreenState extends State<PickupTimeScreen> {
  int day = 0;
  String? selected;
  static const slots = ['11.45–12.00', '12.00–12.15', '12.15–12.30', '12.30–12.45', '12.45–13.00', '13.00–13.15'];
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final c = Theme.of(context).colorScheme;
    final canteen = store.canteenById(store.cartLines.isEmpty ? 'kantin_a' : store.cartLines.first.food.canteenId);
    return Scaffold(appBar: AppBar(title: const Text('Waktu pengambilan')), body: ListView(padding: const EdgeInsets.all(20), children: [
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.storefront_outlined, color: c.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${canteen.name} · Loket A', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 6), Text(canteen.location, style: Theme.of(context).textTheme.bodySmall)]))]),
        const SizedBox(height: 16), Text('Ambil sendiri · Persiapan ${canteen.prepTime}', style: TextStyle(color: c.primary, fontSize: 13)),
      ])),
      const SizedBox(height: 24), Text('Kapan mau ambil?', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 16),
      const Text('Pilih waktu yang cocok dengan jam istirahatmu. Slot penuh tidak dapat dipilih.'), const SizedBox(height: 20),
      Wrap(spacing: 8, children: [ChoiceChip(label: const Text('Hari ini'), selected: day == 0, onSelected: (_) => setState(() { day = 0; selected = null; })), ChoiceChip(label: const Text('Besok'), selected: day == 1, onSelected: (_) => setState(() { day = 1; selected = null; }))]),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, constraints) => Wrap(spacing: 12, runSpacing: 12, children: [
        for (var i = 0; i < slots.length; i++) SizedBox(width: (constraints.maxWidth - 12) / 2, child: _slot(context, slots[i], i == 0 || i == 5)),
      ])),
      const SizedBox(height: 18), const InfoBox('Pesan minimal 20 menit sebelum waktu ambil. Datang setelah status pesanan Siap diambil.'),
    ]), bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: AppButton(label: selected == null ? 'Pilih waktu ambil' : 'Pilih $selected', onPressed: selected == null ? null : () { store.setPickupSlot('${day == 0 ? 'Hari ini' : 'Besok'} · $selected'); Navigator.pop(context); }))));
  }
  Widget _slot(BuildContext context, String slot, bool full) {
    final c = Theme.of(context).colorScheme;
    final active = selected == slot;
    return Material(color: full ? c.surfaceContainerHighest : active ? c.primaryContainer : c.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: active ? c.primary : c.outlineVariant)), clipBehavior: Clip.antiAlias, child: InkWell(onTap: full ? null : () => setState(() => selected = slot), child: Padding(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5), child: Column(children: [
      Text(slot, style: TextStyle(fontWeight: FontWeight.w700, color: full ? c.outline : c.onSurface)), const SizedBox(height: 8), Text(full ? 'Penuh' : active ? 'Terpilih' : 'Tersedia', style: TextStyle(fontSize: 12, color: full ? c.error : c.primary)),
    ]))));
  }
}
