class Canteen {
  const Canteen({required this.id, required this.name, required this.image,
    required this.categories, required this.location, required this.description,
    this.openingHours = '09.00–15.00', this.prepTime = '15–20 menit', this.isOpen = true});
  final String id, name, image, categories, location, description, openingHours, prepTime;
  final bool isOpen;
}
