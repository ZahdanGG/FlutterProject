import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';

class PickupTimeScreen extends StatefulWidget {
  const PickupTimeScreen({super.key});
  @override
  State<PickupTimeScreen> createState() => _PickupTimeScreenState();
}

class _PickupTimeScreenState extends State<PickupTimeScreen> {
  DateTime? selectedDate;
  String? selected;
  static const slots = ['11.45–12.00', '12.00–12.15', '12.15–12.30', '12.30–12.45', '12.45–13.00', '13.00–13.15'];
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final c = Theme.of(context).colorScheme;
    final now = store.currentTime;
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = selectedDate ?? store.pickupDate;
    final day = date.year == today.year && date.month == today.month && date.day == today.day ? 0 : 1;
    final canteen = store.canteenById(store.cartLines.isEmpty ? 'kantin_a' : store.cartLines.first.food.canteenId);
    return Scaffold(appBar: AppBar(title: const Text('Waktu pengambilan')), body: ListView(padding: const EdgeInsets.all(20), children: [
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.storefront_outlined, color: c.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${canteen.name} · Loket A', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 6), Text(canteen.location, style: Theme.of(context).textTheme.bodySmall)]))]),
        const SizedBox(height: 16), Text('Ambil sendiri · Persiapan ${canteen.prepTime}', style: TextStyle(color: c.primary, fontSize: 13)),
      ])),
      const SizedBox(height: 24), Text('Kapan mau ambil?', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 16),
      const Text('Pilih waktu yang cocok dengan jam istirahatmu. Slot penuh tidak dapat dipilih.'), const SizedBox(height: 20),
      Wrap(spacing: 8, children: [ChoiceChip(label: const Text('Hari ini'), selected: day == 0, onSelected: (_) => setState(() { selectedDate = today; selected = null; })), ChoiceChip(label: const Text('Besok'), selected: day == 1, onSelected: (_) => setState(() { selectedDate = tomorrow; selected = null; }))]),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, constraints) => Wrap(spacing: 12, runSpacing: 12, children: [
        for (var i = 0; i < slots.length; i++) SizedBox(width: (constraints.maxWidth - 12) / 2, child: _slot(context, slots[i], !store.isPickupSlotAvailable(slots[i], date: date), i == 0 || i == 5)),
      ])),
      const SizedBox(height: 18), const InfoBox('Pesan minimal 20 menit sebelum waktu ambil. Slot yang telah lewat tidak dapat dipilih. Datang setelah status pesanan Siap diambil.'),
    ]), bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: AppButton(label: selected == null ? 'Pilih waktu ambil' : 'Pilih $selected', onPressed: selected == null || !store.isPickupSlotAvailable(selected!, date: date) ? null : () { try { store.setPickupDate(date); store.setPickupSlot(selected); Navigator.pop(context); } catch (error) { showMessage(context, error.toString()); } }))));
  }
  Widget _slot(BuildContext context, String slot, bool disabled, bool full) {
    final c = Theme.of(context).colorScheme;
    final active = selected == slot;
    return Material(color: disabled ? c.surfaceContainerHighest : active ? c.primaryContainer : c.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: active ? c.primary : c.outlineVariant)), clipBehavior: Clip.antiAlias, child: InkWell(onTap: disabled ? null : () => setState(() => selected = slot), child: Padding(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5), child: Column(children: [
      Text(slot, style: TextStyle(fontWeight: FontWeight.w700, color: disabled ? c.outline : c.onSurface)), const SizedBox(height: 8), Text(disabled ? (full ? 'Penuh' : 'Tidak tersedia') : active ? 'Terpilih' : 'Tersedia', style: TextStyle(fontSize: 12, color: disabled ? c.error : c.primary)),
    ]))));
  }
}
