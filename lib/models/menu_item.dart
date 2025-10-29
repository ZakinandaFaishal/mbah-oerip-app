// Model ini untuk mem-parsing data "category"
// yang ada di dalam setiap item menu dari API Anda
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0, // Fallback jika id null
      name: json['name'] ?? 'Tanpa Kategori', // Fallback jika name null
    );
  }
}

// Ini adalah model PRODUK Anda, sesuai dengan data Postman
class MenuItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final Category category; // <-- Penting! Ini adalah data kategori

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
      // Parsing objek 'category' yang ada di dalam 'MenuItem'
      category: Category.fromJson(json['category']),
    );
  }
}

// Ini adalah model KATEGORI Anda, yang digunakan oleh UI
// (Ini berisi daftar produk)
class Menu {
  final int id;
  final String name;
  final List<MenuItem> menuItems;

  Menu({required this.id, required this.name, required this.menuItems});
}
