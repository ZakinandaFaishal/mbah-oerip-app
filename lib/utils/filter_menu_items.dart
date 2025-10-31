import '../models/menu_item.dart';

List<MenuItem> filterMenuItems(
  List<MenuItem> items, {
  required String category,
  required String query,
}) {
  // Filter kategori
  List<MenuItem> filtered = category == 'Semua'
      ? items
      : items.where((i) => i.category.name == category).toList();

  // Filter pencarian
  if (query.trim().isNotEmpty) {
    final q = query.toLowerCase();
    filtered = filtered.where((i) {
      final name = i.name.toLowerCase();
      final desc = (i.description ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }
  return filtered;
}
