class Menu {
  final int id;
  final String name;
  final String description;
  final String category;
  final String unit;
  final int price;
  final int isAvailable;
  final String imagePath;

  Menu(
      {this.id,
      this.name,
      this.description,
      this.category,
      this.unit,
      this.price,
      this.isAvailable,
      this.imagePath});

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['menu_type'],
      unit: json['unit'],
      price: json['price'],
      isAvailable: json['is_available'],
      imagePath: json['image_path']);
}
