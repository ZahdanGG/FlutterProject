import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/food_widgets.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key, this.initialQuery = ''});
  final String initialQuery;
  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late final TextEditingController _search;
  String _category = 'Semua';
  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialQuery);
  }
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final query = _search.text.trim().toLowerCase();
    final foods = store.foods.where((food) => matchesCategory(food, _category) && (food.name.toLowerCase().contains(query) || store.canteenById(food.canteenId).name.toLowerCase().contains(query))).toList();
    final related = store.canteens.where((canteen) => canteen.name.toLowerCase().contains(query) || foods.any((food) => food.canteenId == canteen.id)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(query.isEmpty ? 'Semua menu' : 'Pencarian')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(hintText: 'Cari makanan favoritmu', prefixIcon: const Icon(Icons.search), suffixIcon: query.isEmpty ? null : IconButton(tooltip: 'Hapus pencarian', onPressed: () => setState(_search.clear), icon: const Icon(Icons.close))),
        ),
        const SizedBox(height: 12),
        if (query.isEmpty) CatalogChips(value: _category, onChanged: (value) => setState(() => _category = value))
        else Text('${foods.length} menu ditemukan untuk “${_search.text.trim()}”', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        if (foods.isEmpty) ...[
          EmptyState(icon: Icons.search_off, title: 'Menu belum ditemukan', message: 'Coba kata yang lebih sederhana atau cari nama kantin.', action: AppButton(label: 'Hapus pencarian', onPressed: () => setState(() { _search.clear(); _category = 'Semua'; }))),
          Text('Coba cari', style: Theme.of(context).textTheme.titleMedium),
          Wrap(spacing: 8, children: ['Nasi', 'Mie ayam', 'Es teh'].map((text) => ActionChip(label: Text(text), onPressed: () => setState(() { _search.text = text; _category = 'Semua'; }))).toList()),
        ] else ...foods.map((food) => Padding(padding: const EdgeInsets.only(bottom: 12), child: FoodListTile(food: food, showAdd: query.isNotEmpty))),
        if (query.isNotEmpty && foods.isNotEmpty) ...[
          const SizedBox(height: 10),
          const SectionHeading('Kantin terkait'),
          const SizedBox(height: 12),
          ...related.map((canteen) => Padding(padding: const EdgeInsets.only(bottom: 12), child: AppCard(
            onTap: () => Navigator.pushNamed(context, '/canteen', arguments: canteen),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(canteen.name, style: Theme.of(context).textTheme.titleMedium)), Text(canteen.isOpen ? 'Buka' : 'Tutup')]),
              const SizedBox(height: 12),
              Text('${canteen.categories} · ${canteen.openingHours}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: Text('Persiapan ${canteen.prepTime}', style: Theme.of(context).textTheme.bodySmall)), const Text('Lihat menu', style: TextStyle(fontWeight: FontWeight.w600))]),
            ]),
          ))),
        ],
      ]),
    );
  }
}
