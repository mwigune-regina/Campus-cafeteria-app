class MenuItemModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
    };
  }
}
