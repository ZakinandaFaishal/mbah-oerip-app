class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Kategori',
    );
  }
}

class MenuItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final Category category;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image_url'],
      category: Category.fromJson(json['category']),
    );
  }
}

class Menu {
  final int id;
  final String name;
  final List<MenuItem> menuItems;

  Menu({required this.id, required this.name, required this.menuItems});
}
