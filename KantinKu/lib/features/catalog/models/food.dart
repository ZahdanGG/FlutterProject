/// Menu menggunakan harga rupiah bulat agar total tidak terpengaruh pembulatan.
class Food {
  const Food({required this.id, required this.name, required this.canteenId,
    required this.category, required this.price, required this.image,
    required this.description, this.available = true, this.prepTime = '15–20 menit'});
  final String id, name, canteenId, category, image, description, prepTime;
  final int price;
  final bool available;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'canteenId': canteenId,
    'category': category, 'price': price, 'image': image, 'description': description,
    'available': available, 'prepTime': prepTime};
  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json['id'] as String, name: json['name'] as String,
    canteenId: json['canteenId'] as String, category: json['category'] as String,
    price: json['price'] as int, image: json['image'] as String,
    description: json['description'] as String, available: json['available'] as bool? ?? true,
    prepTime: json['prepTime'] as String? ?? '15–20 menit');
}
