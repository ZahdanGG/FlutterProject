import 'package:flutter/material.dart';
import '../../../../app/app_router.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/formatters.dart';
import '../../../order/models/kantin_order.dart';
import '../widgets/food_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'Semua';
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final logged = store.isLoggedIn;
    final foods = store.foods.where((f) => f.available && matchesCategory(f, _category)).toList();
    if (_category == 'Semua') {
      const rank = {'geprek': 0, 'mie_ayam': 1};
      foods.sort((a, b) => (rank[a.id] ?? 2).compareTo(rank[b.id] ?? 2));
    }
    final active = store.orders.where((o) => o.status.isActive).toList();
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const PageStorageKey('home_scroll'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(children: [
          if (logged)
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.soup_kitchen_outlined, color: colors.primary, size: 24))
          else ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/images/branding/guest_logo.png', width: 36, height: 36)),
          const SizedBox(width: 10),
          Text('KantinKu', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800, fontSize: 24)),
          const Spacer(),
          IconButton(onPressed: () => logged ? AppRouter.goTab(context, 1) : Navigator.pushNamed(context, '/notifications'), tooltip: logged ? 'Lihat pesanan' : 'Notifikasi', icon: Icon(logged ? Icons.assignment_outlined : Icons.notifications_none, color: colors.primary)),
        ]),
        if (logged) ...[
          const SizedBox(height: 14),
          Text('Mau makan apa, ${store.user?.name.split(' ').first ?? 'Anjari'}?', style: Theme.of(context).textTheme.headlineSmall),
        ],
        const SizedBox(height: 20),
        TextField(
          readOnly: true,
          onTap: () => Navigator.pushNamed(context, '/menus'),
          decoration: InputDecoration(hintText: 'Cari menu atau kantin', prefixIcon: const Icon(Icons.search), suffixIcon: logged ? null : IconButton(tooltip: 'Filter menu', onPressed: () => Navigator.pushNamed(context, '/filter'), icon: const Icon(Icons.tune))),
        ),
        const SizedBox(height: 14),
        CatalogChips(value: _category, labels: logged ? const ['Semua', 'Ayam', 'Mie', 'Minuman'] : const ['Semua', 'Ayam', 'Nasi', 'Minuman'], onChanged: (value) => setState(() => _category = value)),
        const SizedBox(height: 16),
        _HomeBanner(logged: logged),
        if (logged && active.isNotEmpty) ...[
          const SizedBox(height: 20),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Chip(label: Text(active.first.status.label), backgroundColor: colors.secondaryContainer),
              Text('#${active.first.id}', style: Theme.of(context).textTheme.bodySmall),
            ]),
            const SizedBox(height: 6),
            Text(active.first.status == OrderStatus.ready ? 'Makananmu siap diambil' : 'Makan siangmu sedang disiapkan', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(children: [Expanded(child: Text('Ambil ${active.first.pickupSlot}', style: Theme.of(context).textTheme.bodySmall)), TextButton(onPressed: () => Navigator.pushNamed(context, '/order-detail', arguments: active.first), child: const Text('Lihat status'))]),
          ])),
        ],
        const SizedBox(height: 12),
        SectionHeading('Menu populer', actionLabel: 'Lihat semua', onAction: () => Navigator.pushNamed(context, '/menus')),
        const SizedBox(height: 10),
        if (foods.isEmpty)
          const Text('Menu pada kategori ini belum tersedia.')
        else if (!logged)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: FoodGridCard(food: foods.first)),
            const SizedBox(width: 12),
            Expanded(child: foods.length > 1 ? FoodGridCard(food: foods[1]) : const SizedBox()),
          ])
        else ...foods.take(3).map((food) => Padding(padding: const EdgeInsets.only(bottom: 14), child: AppCard(
          padding: EdgeInsets.zero,
          onTap: () => Navigator.pushNamed(context, '/menu', arguments: food),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FoodPhoto(food.image, width: double.infinity, height: 180, radius: 16),
            Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(food.name, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 4), Text(store.canteenById(food.canteenId).name, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 4), Text(rupiah(food.price), style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700)),])),
          ]),
        ))),
        const SizedBox(height: 12),
        SectionHeading('Kantin yang buka', actionLabel: 'Lihat semua', onAction: () => AppRouter.goTab(context, 2)),
        const SizedBox(height: 10),
        ...store.canteens.where((c) => c.isOpen).take(logged ? 3 : 1).map((canteen) => Padding(padding: const EdgeInsets.only(bottom: 12), child: AppCard(
          onTap: () => Navigator.pushNamed(context, '/canteen', arguments: canteen),
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            FoodPhoto(canteen.image, width: 66, height: 66, radius: 12),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(canteen.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${canteen.categories} · ${canteen.openingHours}', style: Theme.of(context).textTheme.bodySmall),
              Text(canteen.location, style: Theme.of(context).textTheme.bodySmall),
            ])),
            const SizedBox(width: 4),
            Text('Buka', style: TextStyle(fontSize: 11, color: colors.tertiary, fontWeight: FontWeight.w600)),
          ]),
        ))),
        if (!logged) Row(children: [Icon(Icons.person_outline, color: colors.primary, size: 18), const SizedBox(width: 8), Expanded(child: Text('Mode tamu · Masuk untuk mulai memesan', style: Theme.of(context).textTheme.bodySmall))]),
        if (store.cartCount > 0) ...[
          const SizedBox(height: 16),
          AppButton(label: 'Lihat keranjang (${store.cartCount})', icon: Icons.shopping_basket_outlined, onPressed: () => Navigator.pushNamed(context, '/cart')),
        ],
      ],
    );
  }
}

class _HomeBanner extends StatelessWidget {
  const _HomeBanner({required this.logged});
  final bool logged;
  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: const Color(0xFF002E63), borderRadius: BorderRadius.circular(24)),
    child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(flex: logged ? 63 : 70, child: Padding(
        padding: EdgeInsets.all(logged ? 16 : 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(logged ? 'Pesan dulu,\nambil saat siap.' : 'Pesan dulu, ambil\nsaat siap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: logged ? 20 : 18)),
          const SizedBox(height: 8),
          Text(logged ? 'Waktu istirahatmu lebih berharga.' : 'Istirahat lebih santai, tanpa antre.', style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: logged ? 14 : 11)),
          if (logged) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEEF4FA), foregroundColor: const Color(0xFF002E63)), onPressed: () => AppRouter.goTab(context, 2), child: const Text('Cari kantin'))),
          ],
        ]),
      )),
      Expanded(flex: logged ? 37 : 30, child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(logged ? 'assets/images/branding/banner_canteen.png' : 'assets/images/foods/nasi_ayam_geprek.png', fit: BoxFit.cover))),
    ])),
  );
}
