import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'menu_detail_screen.dart';
import 'cart_screen.dart';

// Widgets terpisah
import '../widgets/menu/outlet_appbar_title.dart';
import '../widgets/menu/cart_icon_button.dart';
import '../widgets/menu/menu_body.dart';

// Utils
import '../utils/snackbar_utils.dart';

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

  final List<String> _outlets = const [
    'Jl. Semarang - Yogyakarta',
    'Jl. Muntilan - Borobudur',
    'Jl. Magelang - Yogyakarta',
  ];
  String _selectedOutlet = 'Jl. Semarang - Yogyakarta';

  late Future<List<MenuItem>> _menuFuture;

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
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: OutletAppBarTitle(
          brandTitle: 'Ingkung Eco Mbah Oerip',
          outlets: _outlets,
          selected: _selectedOutlet,
          onChanged: (val) => setState(() => _selectedOutlet = val),
        ),
        actions: const [CartIconButton(), SizedBox(width: 4)],
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

          return MenuBody(
            idr: idr,
            allMenuItems: allMenuItems,
            selectedCategory: _selectedCategory,
            onSelectedCategory: (cat) =>
                setState(() => _selectedCategory = cat),
            searchController: _searchCtrl,
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onSearchSubmitted: (v) {
              _searchDebounce?.cancel();
              setState(() => _searchQuery = v);
            },
            onSearchClear: () {
              _searchCtrl.clear();
              _searchDebounce?.cancel();
              setState(() => _searchQuery = '');
            },
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
              showModernSnackBar(
                context,
                message: '${item.name} ditambahkan ke keranjang',
                icon: Icons.check_circle,
                color: Colors.green.shade600,
                actionLabel: 'Lihat',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
