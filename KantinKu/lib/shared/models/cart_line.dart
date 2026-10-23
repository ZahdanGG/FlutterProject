import '../../features/catalog/models/food.dart';

class CartLine {
  const CartLine({required this.food, required this.quantity, this.note = ''});
  final Food food;
  final int quantity;
  final String note;
  int get total => food.price * quantity;
  CartLine copyWith({int? quantity, String? note}) =>
      CartLine(food: food, quantity: quantity ?? this.quantity, note: note ?? this.note);
  Map<String, dynamic> toJson() => {'food': food.toJson(), 'quantity': quantity, 'note': note};
  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    food: Food.fromJson(Map<String, dynamic>.from(json['food'] as Map)),
    quantity: json['quantity'] as int, note: json['note'] as String? ?? '');
}
