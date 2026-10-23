import 'package:flutter/material.dart';
import '../../../../app/app_scope.dart';
import '../../../../app/app_stage.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../catalog/models/food.dart';

class MenuDetailScreen extends StatefulWidget {
  const MenuDetailScreen({super.key, required this.food});
  final Food food;
  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  final _note = TextEditingController();
  int _quantity = 1;
  String _option = '';
  bool _adding = false;
  @override
  void initState() {
    super.initState();
    _option = widget.food.category == 'Minuman' ? 'Normal' : 'Sedang';
  }
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }
  Future<bool> _requireLogin() async {
    final store = AppScope.of(context);
    if (store.isLoggedIn) return true;
    final action = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.login),
      title: const Text('Masuk dulu untuk memesan'),
      content: const Text('Kamu tetap bisa melihat menu. Masuk atau daftar untuk memesan dan mengambil makanan saat siap.'),
      actions: [
        AppButton(label: 'Masuk', onPressed: () => Navigator.pop(dialogContext, '/login')),
        const SizedBox(height: 8),
        AppButton(label: 'Daftar', outlined: true, onPressed: () => Navigator.pop(dialogContext, '/register-role')),
        Center(child: TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Lanjut melihat'))),
      ],
    ));
    if (!mounted || action == null) return false;
    if (AppStage.current == 1) {
      await foundationNotice(context);
      return false;
    }
    await Navigator.pushNamed(context, action);
    return mounted && store.isLoggedIn;
  }
  Future<void> _addToCart() async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      final store = AppScope.of(context);
      if (!await _requireLogin() || !mounted) return;
      final canteen = store.canteenById(widget.food.canteenId);
      if (!canteen.isOpen || !widget.food.available) return;
      if (store.cartLines.isNotEmpty && store.cartLines.first.food.canteenId != widget.food.canteenId) {
        final replace = await confirmAction(context, title: 'Ganti keranjang?', message: 'Keranjangmu berisi ${store.cartCount} item dari ${store.canteenById(store.cartLines.first.food.canteenId).name}. Menambahkan menu ${canteen.name} akan mengganti isi keranjang sebelumnya.', confirmLabel: 'Ganti ke ${canteen.name}');
        if (!replace || !mounted) return;
        store.clearCart();
      }
      final note = _note.text.trim().isEmpty ? _option : '$_option · ${_note.text.trim()}';
      store.addToCart(widget.food, quantity: _quantity, note: note);
      if (!mounted) return;
      await Navigator.pushNamed(context, '/cart');
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final food = widget.food;
    final canteen = store.canteenById(food.canteenId);
    final colors = Theme.of(context).colorScheme;
    final available = food.available && canteen.isOpen;
    final drink = food.category == 'Minuman';
    final favorite = store.favoriteIds.contains(food.id);
    return Scaffold(
      appBar: AppBar(title: Text(food.name, style: const TextStyle(fontSize: 18)), actions: [
        IconButton(tooltip: favorite ? 'Hapus dari favorit' : 'Tambah ke favorit', onPressed: () async {
          if (!await _requireLogin() || !mounted) return;
          store.toggleFavorite(food.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(favorite ? 'Dihapus dari Favorit' : 'Ditambahkan ke Favorit'), action: SnackBarAction(label: favorite ? 'Urungkan' : 'Lihat Favorit', onPressed: () { if (favorite) { store.toggleFavorite(food.id); } else { Navigator.pushNamed(context, '/favorites'); } })));
        }, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: colors.primary)),
        const SizedBox(width: 8),
      ]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 16), children: [
        FoodPhoto(food.image, height: 180, width: double.infinity, radius: 16),
        const SizedBox(height: 10),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: available ? colors.secondaryContainer : colors.errorContainer, borderRadius: BorderRadius.circular(20)), child: Text(available ? 'Tersedia' : canteen.isOpen ? 'Habis hari ini' : 'Tutup', style: TextStyle(color: available ? colors.tertiary : colors.onErrorContainer, fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/canteen', arguments: canteen), child: Text(canteen.name)),
        ]),
        const SizedBox(height: 8),
        Text(food.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(rupiah(food.price), style: TextStyle(color: colors.primary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(food.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
        const SizedBox(height: 12),
        InfoBox(canteen.isOpen ? 'Disiapkan dalam ${food.prepTime}' : 'Tutup hari ini. Buka lagi besok pukul 08.00.', icon: Icons.schedule, error: !canteen.isOpen),
        const SizedBox(height: 12),
        Text('Pilihan menu', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(drink ? 'Tingkat manis' : 'Tingkat pedas', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _option,
          items: (drink ? ['Normal', 'Sedikit gula', 'Tanpa gula'] : ['Tidak pedas', 'Sedang', 'Pedas']).map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          onChanged: available ? (value) => setState(() => _option = value ?? _option) : null,
        ),
        const SizedBox(height: 12),
        const Text('Catatan (opsional)', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(controller: _note, enabled: available, maxLength: 200, decoration: InputDecoration(hintText: drink ? 'Manis normal' : 'Tidak terlalu pedas', counterText: '')),
        const SizedBox(height: 12),
        Row(children: [const Expanded(child: Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w600))), QuantitySelector(value: _quantity, onChanged: (value) => setState(() => _quantity = value))]),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium)), Text(rupiah(food.price * _quantity), style: TextStyle(color: colors.primary, fontSize: 20, fontWeight: FontWeight.w700))]),
      ]),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: AppButton(label: available ? 'Tambah ke keranjang' : canteen.isOpen ? 'Menu habis hari ini' : 'Kantin sedang tutup', loading: _adding, onPressed: available ? _addToCart : null))),
    );
  }
}
