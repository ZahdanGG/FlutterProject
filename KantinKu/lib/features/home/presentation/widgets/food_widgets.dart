import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../catalog/models/food.dart';

class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.food, this.onTap, this.showAdd = false});
  final Food food;
  final VoidCallback? onTap;
  final bool showAdd;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final canteen = store.canteenById(food.canteenId);
    final available = food.available && canteen.isOpen;
    void open() => Navigator.pushNamed(context, '/menu', arguments: food);
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap ?? open,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FoodPhoto(food.image, width: 76, height: 88, radius: 12),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(canteen.name, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(rupiah(food.price), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(available ? 'Tersedia' : canteen.isOpen ? 'Habis hari ini' : 'Kantin sedang tutup', style: TextStyle(fontSize: 12, color: available ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error)),
        ])),
        if (showAdd) IconButton.filled(
          onPressed: available ? (onTap ?? open) : null,
          tooltip: available ? 'Pilih ${food.name}' : 'Menu tidak tersedia',
          icon: const Icon(Icons.add, size: 20),
          visualDensity: VisualDensity.compact,
        ),
      ]),
    );
  }
}

class FoodGridCard extends StatelessWidget {
  const FoodGridCard({super.key, required this.food});
  final Food food;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    onTap: () => Navigator.pushNamed(context, '/menu', arguments: food),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FoodPhoto(food.image, width: double.infinity, height: 92, radius: 14),
      Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(food.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2),
        const SizedBox(height: 3),
        Text(AppScope.of(context).canteenById(food.canteenId).name, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
        Text(rupiah(food.price), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 14)),
        const SizedBox(height: 3),
        Text('Tersedia · ${food.prepTime}', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary)),
      ])),
    ]),
  );
}

class CatalogChips extends StatelessWidget {
  const CatalogChips({super.key, required this.value, required this.onChanged, this.labels = const ['Semua', 'Ayam', 'Mie', 'Minuman']});
  final String value;
  final ValueChanged<String> onChanged;
  final List<String> labels;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: labels.map((label) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: value == label, showCheckmark: false, onSelected: (_) => onChanged(label)),
    )).toList()),
  );
}

bool matchesCategory(Food food, String category) {
  if (category == 'Semua') return true;
  if (category == 'Makanan') return food.category != 'Minuman';
  if (category == 'Ayam') return food.name.toLowerCase().contains('ayam');
  if (category == 'Nasi') return food.name.toLowerCase().contains('nasi');
  if (category == 'Mie') return food.name.toLowerCase().contains('mie');
  return food.category == category;
}
