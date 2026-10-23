import '../models/canteen.dart';
import '../models/food.dart';

/// Katalog lokal dari teks ekspor desain. Perubahan harga cukup di tempat ini.
class CatalogRepository {
  const CatalogRepository();
  static const canteens = <Canteen>[
    Canteen(id: 'kantin_a', name: 'Kantin A', image: 'assets/images/canteens/kantin_a.png',
      categories: 'Nasi · Ayam · Masakan rumahan', location: 'Area kantin • Gedung utama',
      description: 'Masakan rumahan, ayam, dan nasi.'),
    Canteen(id: 'kantin_b', name: 'Kantin B', image: 'assets/images/canteens/kantin_b.png',
      categories: 'Mie · Bakso · Soto', location: 'Area kantin • Gedung utama',
      description: 'Mie, soto, dan kuah hangat.'),
    Canteen(id: 'kantin_c', name: 'Kantin C', image: 'assets/images/canteens/kantin_c.png',
      categories: 'Minuman · Kopi · Camilan', location: 'Area kantin • Gedung utama',
      description: 'Minuman segar dan camilan.'),
    Canteen(id: 'kantin_d', name: 'Kantin D', image: 'assets/images/canteens/kantin_d.png',
      categories: 'Soto · Masakan rumahan', location: 'Area kantin • Gedung utama',
      description: 'Menu sarapan dan masakan harian.', isOpen: false,
      openingHours: 'Buka besok 08.00'),
  ];
  static const foods = <Food>[
    Food(id: 'geprek', name: 'Nasi ayam geprek', canteenId: 'kantin_a', category: 'Ayam',
      price: 18000, image: 'assets/images/foods/nasi_ayam_geprek.png',
      description: 'Nasi hangat, ayam renyah, lalapan, dan sambal ulek. Pilih tingkat pedas sesuai selera.'),
    Food(id: 'nasi_goreng', name: 'Nasi goreng kampung', canteenId: 'kantin_a', category: 'Nasi',
      price: 20000, image: 'assets/images/foods/nasi_goreng_kampung.png',
      description: 'Nasi goreng dengan ayam, telur, acar, dan bumbu rumahan yang gurih.'),
    Food(id: 'mie_ayam', name: 'Mie ayam', canteenId: 'kantin_b', category: 'Mie',
      price: 16000, image: 'assets/images/foods/mie_ayam.png', prepTime: '10–15 menit',
      description: 'Mie lembut dengan ayam kecap, sawi, kuah hangat, dan pangsit.'),
    Food(id: 'es_teh', name: 'Es teh manis', canteenId: 'kantin_a', category: 'Minuman',
      price: 5000, image: 'assets/images/foods/es_teh_manis.png', prepTime: '5–10 menit',
      description: 'Teh segar dengan es batu. Pilih manis normal atau sedikit gula.'),
    Food(id: 'soto_ayam', name: 'Soto ayam', canteenId: 'kantin_b', category: 'Ayam',
      price: 18000, image: 'assets/images/foods/soto_ayam.png',
      description: 'Soto ayam hangat dengan bihun, kol, dan jeruk nipis. Porsi nasi terpisah.'),
    Food(id: 'soto_ayam_d', name: 'Soto ayam', canteenId: 'kantin_d', category: 'Ayam',
      price: 18000, image: 'assets/images/foods/soto_ayam.png', available: false,
      description: 'Kantin D sedang tutup. Buka kembali besok 08.00.'),
    Food(id: 'kopi_susu', name: 'Kopi susu', canteenId: 'kantin_c', category: 'Minuman',
      price: 10000, image: 'assets/images/foods/kopi_susu.png', available: false,
      description: 'Kopi susu. Menu ini sedang habis.'),
    Food(id: 'ayam_bakar', name: 'Ayam Bakar', canteenId: 'kantin_c', category: 'Ayam',
      price: 25000, image: 'assets/images/foods/ayam_bakar.png',
      description: 'Ayam bakar berbumbu dengan nasi dan lalapan.'),
  ];
}
