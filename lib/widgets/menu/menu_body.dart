import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/menu_item.dart';
import '../../utils/filter_menu_items.dart';
import 'menu_search_bar.dart';
import 'category_filter_chips.dart';
import 'menu_grid.dart';
import 'empty_menu_state.dart';

class MenuBody extends StatelessWidget {
  final NumberFormat idr;
  final List<MenuItem> allMenuItems;

  final String selectedCategory;
  final ValueChanged<String> onSelectedCategory;

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchClear;

  final ValueChanged<MenuItem> onItemTap;
  final ValueChanged<MenuItem> onAddCart;

  const MenuBody({
    super.key,
    required this.idr,
    required this.allMenuItems,
    required this.selectedCategory,
    required this.onSelectedCategory,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onSearchClear,
    required this.onItemTap,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Semua',
      ...allMenuItems.map((item) => item.category.name).toSet().toList(),
    ];

    final filteredItems = filterMenuItems(
      allMenuItems,
      category: selectedCategory,
      query: searchQuery,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: MenuSearchBar(
            controller: searchController,
            query: searchQuery,
            hintText: 'Cari menu...',
            onChanged: onSearchChanged,
            onSubmitted: onSearchSubmitted,
            onClear: onSearchClear,
          ),
        ),
        SizedBox(
          height: 48,
          child: CategoryFilterChips(
            categories: categories,
            selected: selectedCategory,
            onSelected: onSelectedCategory,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filteredItems.isEmpty
              ? const EmptyMenuState()
              : MenuGrid(
                  items: filteredItems,
                  idr: idr,
                  onItemTap: onItemTap,
                  onAddCart: onAddCart,
                ),
        ),
      ],
    );
  }
}
