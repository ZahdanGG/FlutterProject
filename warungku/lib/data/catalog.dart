/// Menu data taken from the Figma frames (Semua Menu grid + Order cart).
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.tags,
    this.warung,
    this.rating,
    this.time,
    this.badge,
    this.image,
    this.categories = const [],
  });

  final String id;
  final String name;
  final int price;
  final String tags;
  final String? warung;
  final double? rating;
  final String? time;
  final String? badge;
  final String? image;
  final List<String> categories;
}

const imgPaketHemat = 'assets/images/paket_hemat.png';
const imgMieAyam = 'assets/images/mie_ayam.png';
const imgIkanGoreng = 'assets/images/ikan_goreng.png';
const imgNasiGorengKampung = 'assets/images/nasi_goreng_kampung.png';
const imgAyamBakar = 'assets/images/ayam_bakar.png';
const imgTelurBalado = 'assets/images/telur_balado.png';
const imgPromoSalad = 'assets/images/promo_salad.png';

/// "Semua Menu" grid, in Figma reading order (left column = even index,
/// right column = odd index).
const List<MenuItem> kMenuGrid = [
  MenuItem(
    id: 'nasi-ayam-geprek',
    name: 'Nasi Ayam Geprek',
    tags: 'Nasi • Ayam',
    warung: 'WARUNG A',
    rating: 4.8,
    time: '15–20 min',
    price: 18000,
    badge: 'Promo',
    image: imgPaketHemat,
    categories: ['Nasi', 'Ayam'],
  ),
  MenuItem(
    id: 'nasi-goreng-kampung',
    name: 'Nasi Goreng Kampung',
    tags: 'Nasi • Sosis',
    rating: 4.6,
    time: '10–15 min',
    price: 20000,
    image: imgNasiGorengKampung,
    categories: ['Nasi'],
  ),
  MenuItem(
    id: 'mie-ayam',
    name: 'Mie Ayam',
    tags: 'Mie • Ayam',
    rating: 4.7,
    time: '15 min',
    price: 16000,
    badge: 'Best Seller',
    image: imgMieAyam,
    categories: ['Mie', 'Ayam'],
  ),
  MenuItem(
    id: 'ayam-bakar',
    name: 'Ayam Bakar',
    tags: 'Ayam',
    rating: 4.9,
    time: '20 min',
    price: 25000,
    image: imgAyamBakar,
    categories: ['Ayam'],
  ),
  MenuItem(
    id: 'ikan-goreng',
    name: 'Ikan Goreng',
    tags: 'Ikan',
    rating: 4.7,
    time: '20 min',
    price: 23000,
    image: imgIkanGoreng,
    categories: ['Ikan'],
  ),
  MenuItem(
    id: 'telur-balado',
    name: 'Telur Balado',
    tags: 'Telur',
    rating: 4.6,
    time: '10 min',
    price: 12000,
    badge: 'Promo',
    image: imgTelurBalado,
    categories: ['Telor'],
  ),
];

/// Items that only appear in the Order / Checkout cart in Figma.
/// Mie Ayam Special: Figma shows Rp32.000 with quantity 2 and a subtotal of
/// Rp55.000 (18.000 + 5.000 + 32.000), so 32.000 is the line total and the
/// unit price is 16.000.
const MenuItem kEsTehManis = MenuItem(
  id: 'es-teh-manis',
  name: 'Es Teh Manis',
  tags: 'Minuman',
  warung: 'WARUNG A',
  price: 5000,
  categories: ['Minuman'],
);

const MenuItem kMieAyamSpecial = MenuItem(
  id: 'mie-ayam-special',
  name: 'Mie Ayam Special',
  tags: 'Mie • Ayam',
  warung: 'WARUNG B',
  price: 16000,
  categories: ['Mie', 'Ayam'],
);

final Map<String, MenuItem> kAllItems = {
  for (final i in [...kMenuGrid, kEsTehManis, kMieAyamSpecial]) i.id: i,
};
