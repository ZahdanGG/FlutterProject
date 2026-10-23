import 'package:flutter/material.dart';
import '../core/widgets/app_widgets.dart';
import '../core/utils/formatters.dart';
import '../features/catalog/models/canteen.dart';
import 'app_scope.dart';

class FoundationBrowseScreen extends StatelessWidget {
  const FoundationBrowseScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Browse'), automaticallyImplyLeading: false),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Temukan kantinmu', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      const InfoBox('Tahap UI Dasar: Masih dalam pengembangan'),
      const SizedBox(height: 20),
      AppButton(label: 'Lihat menu', onPressed: () => Navigator.pushNamed(context, '/menus')),
      for (final canteen in AppScope.of(context).canteens) ListTile(
        title: Text(canteen.name), subtitle: Text(canteen.categories),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, '/canteen', arguments: canteen),
      ),
    ]),
  );
}

class CanteenPreviewScreen extends StatelessWidget {
  const CanteenPreviewScreen({super.key, required this.canteen});
  final Canteen canteen;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(canteen.name)),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      FoodPhoto(canteen.image, width: double.infinity, height: 190),
      const SizedBox(height: 16),
      Text(canteen.name, style: Theme.of(context).textTheme.headlineSmall),
      Text(canteen.categories),
      const SizedBox(height: 8),
      Text('${canteen.location}\n${canteen.openingHours} · ${canteen.prepTime}'),
      const SizedBox(height: 20),
      for (final food in AppScope.of(context).foodsForCanteen(canteen.id)) Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(onTap: () => Navigator.pushNamed(context, '/menu', arguments: food), child: Row(children: [
          FoodPhoto(food.image, width: 76, height: 76), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text(rupiah(food.price)), Text(food.available && canteen.isOpen ? 'Tersedia' : 'Tidak tersedia')])),
        ])),
      ),
    ]),
  );
}

class FoundationFeatureScreen extends StatelessWidget {
  const FoundationFeatureScreen({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const InfoBox('Fitur ini termasuk tahap penyempurnaan ZIP 3. Pada tahap ini, gunakan katalog dan preview UI untuk melihat alur.'),
      const SizedBox(height: 20),
      AppButton(label: 'Lihat menu', onPressed: () => Navigator.pushNamed(context, '/menus')),
    ])),
  );
}
