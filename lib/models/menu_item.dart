class MenuItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image_url'],
    );
  }
}

class Zaki {
  final int id;
  final String name;
  final List<MenuItem> menuItems;

  Zaki({required this.id, required this.name, required this.menuItems});

  factory Zaki.fromJson(Map<String, dynamic> json) {
    var items =
        (json['menu_items'] as List<dynamic>? ?? [])
            .map((e) => MenuItem.fromJson(e))
            .toList();
    return Zaki(id: json['id'], name: json['name'], menuItems: items);
  }
}