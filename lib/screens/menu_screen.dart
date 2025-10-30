import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'menu_detail_screen.dart';

// Widgets terpisah
import '../widgets/menu/outlet_appbar_title.dart';
import '../widgets/menu/menu_search_bar.dart';
import '../widgets/menu/category_filter_chips.dart';
import '../widgets/menu/menu_grid.dart';
import '../widgets/menu/empty_menu_state.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final ApiService _apiService = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  // Outlet cabang (dropdown di AppBar)
  final List<String> _outlets = const [
    'Jl. Semarang - Yogyakarta',
    'Jl. Muntilan - Borobudur',
    'Jl. Magelang - Yogyakarta',
  ];
  String _selectedOutlet = 'Jl. Semarang - Yogyakarta';

  // Cache future agar tidak refetch pada setiap setState
  late Future<List<MenuItem>> _menuFuture;

  // Debounce untuk pencarian
  Timer? _searchDebounce;
  static const Duration _searchDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _menuFuture = _apiService.fetchAllMenuItems();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDelay, () {
      if (!mounted) return;
      setState(() => _searchQuery = value);
    });
  }

  List<MenuItem> _filterItems(List<MenuItem> items) {
    // Filter kategori
    List<MenuItem> filtered = _selectedCategory == 'Semua'
        ? items
        : items
              .where((item) => item.category.name == _selectedCategory)
              .toList();

    // Filter pencarian
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final idr = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // center judul
        automaticallyImplyLeading: false, // hilangkan space leading default
        toolbarHeight: 80, // beri ruang untuk 2 baris (brand + dropdown)
        title: OutletAppBarTitle(
          brandTitle: 'Ingkung Eco Mbah Oerip',
          outlets: _outlets,
          selected: _selectedOutlet,
          onChanged: (val) {
            setState(() => _selectedOutlet = val);
            // TODO: filter berdasarkan outlet jika perlu
          },
        ),
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryOrange),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat menu: ${snapshot.error}'));
          }

          final allMenuItems = snapshot.data ?? [];
          final categories = [
            'Semua',
            ...allMenuItems.map((item) => item.category.name).toSet().toList(),
          ];
          final filteredItems = _filterItems(allMenuItems);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: MenuSearchBar(
                  controller: _searchCtrl,
                  query: _searchQuery,
                  hintText: 'Cari menu...',
                  onChanged: _onSearchChanged,
                  onSubmitted: (v) {
                    _searchDebounce?.cancel();
                    setState(() => _searchQuery = v);
                  },
                  onClear: () {
                    _searchCtrl.clear();
                    _searchDebounce?.cancel();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),

              // Category Filter
              SizedBox(
                height: 48,
                child: CategoryFilterChips(
                  categories: categories,
                  selected: _selectedCategory,
                  onSelected: (cat) => setState(() => _selectedCategory = cat),
                ),
              ),

              const SizedBox(height: 12),

              // Menu Grid atau Empty State
              Expanded(
                child: filteredItems.isEmpty
                    ? const EmptyMenuState()
                    : MenuGrid(
                        items: filteredItems,
                        idr: idr,
                        onItemTap: (item) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MenuDetailScreen(
                                item: item,
                                categoryName: item.category.name,
                              ),
                            ),
                          );
                        },
                        onAddCart: (item) {
                          context.read<CartProvider>().addItem(
                            id: item.id,
                            name: item.name,
                            imageUrl: item.imageUrl,
                            priceInIDR: item.price,
                            quantity: 1,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Ditambahkan ke keranjang'),
                              duration: const Duration(milliseconds: 800),
                              action: SnackBarAction(
                                label: 'Buka',
                                onPressed: () {
                                  // TODO: navigate to cart screen
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
