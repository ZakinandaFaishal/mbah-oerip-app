import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../services/location_services.dart';
import '../models/menu_item.dart';
import '../theme.dart';
import 'cart_screen.dart';
import 'menu_detail_screen.dart';
import 'menu_screen.dart';

import '../widgets/home/home_search_bar.dart';
import '../widgets/home/opening_hours_card.dart';
import '../widgets/home/promo_carousel.dart';
import '../widgets/home/home_menu_card.dart';
import '../widgets/home/section_title.dart';
import '../widgets/home/voucher_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final ApiService _api = ApiService();

  late Future<List<MenuItem>> _popularFuture;

  // Search di Home (mirip MenuScreen)
  final TextEditingController _homeSearchCtrl = TextEditingController();
  Timer? _homeSearchDebounce;
  static const Duration _searchDelay = Duration(milliseconds: 500);
  String _homeSearchQuery = '';

  final List<Map<String, String>> _banners = const [
    {
      'image':
          'https://pesonaborobudur.com/assets/upload/berita/berita_ingkung_002.jpg',
      'title': 'Diskon 30%',
      'subtitle': 'Untuk pembelian pertama',
    },
    {
      'image':
          'https://ingkungecombahoerip.web.id/assets/upload/image/slider6.jpg',
      'title': 'Paket Keluarga',
      'subtitle': 'Hemat hingga 25%',
    },
    {
      'image':
          'https://www.pesonaborobudur.com/assets/upload/galeri/Ingkung_Bebek.jpg',
      'title': 'Gratis Ongkir',
      'subtitle': 'Untuk area tertentu 0-5 km',
    },
    {
      'image':
          'https://lh3.googleusercontent.com/gps-cs-s/AG0ilSzdAI_Iu8tmlg22T5ItelnRmdR3ncK94d8xs-CMuLPWvqGbNMrJx-57d7mMdXreBp2Kyfn_3oBC-93PdomzQ_Wpb66HqEJWjPegLa1IiA0A_F9uRPA0iytqCRSrecr4CmG5MV_umw=s680-w680-h510-rw',
      'title': 'November Ceria',
      'subtitle': 'Potongan hingga 30%',
    },
  ];

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _popularFuture = _api.fetchAllMenuItems();
  }

  @override
  void dispose() {
    _homeSearchCtrl.dispose();
    _homeSearchDebounce?.cancel();
    super.dispose();
  }

  void _onHomeSearchChanged(String value) {
    _homeSearchDebounce?.cancel();
    _homeSearchDebounce = Timer(_searchDelay, () {
      if (!mounted) return;
      setState(() => _homeSearchQuery = value);
    });
  }

  List<MenuItem> _filterByQuery(List<MenuItem> items, String q) {
    if (q.trim().isEmpty) return const [];
    final s = q.toLowerCase();
    return items.where((it) {
      final name = it.name.toLowerCase();
      final desc = (it.description ?? '').toLowerCase();
      return name.contains(s) || desc.contains(s);
    }).toList();
  }

  Map<String, int> _todayHours() {
    final loc = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime.now(loc);

    final schedule = <int, Map<String, int>>{
      1: {'open': 8, 'close': 21},
      2: {'open': 8, 'close': 21},
      3: {'open': 8, 'close': 21},
      4: {'open': 8, 'close': 21},
      5: {'open': 8, 'close': 22},
      6: {'open': 6, 'close': 22},
      7: {'open': 6, 'close': 22},
    };

    return schedule[now.weekday] ?? {'open': 8, 'close': 21};
  }

  bool _isOpenNow() {
    final loc = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime.now(loc);
    final h = _todayHours();
    final open = tz.TZDateTime(
      loc,
      now.year,
      now.month,
      now.day,
      h['open']!,
      0,
    );
    final close = tz.TZDateTime(
      loc,
      now.year,
      now.month,
      now.day,
      h['close']!,
      0,
    );
    return now.isAfter(open) && now.isBefore(close);
  }

  String _todayLabel() {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final loc = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime.now(loc);
    return days[now.weekday - 1];
  }

  // Helper: tampilkan snackbar modern
  void _showModernSnackBar({
    required String message,
    required IconData icon,
    required Color color,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // ganti 80 -> 16
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: true);
    final fullName = auth.currentUserData?['fullName'] ?? 'Pelanggan';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0.5,
            backgroundColor: Colors.white,
            expandedHeight: 120,
            leadingWidth: 0,
            leading: const SizedBox.shrink(),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryOrange.withOpacity(.15),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hai, $fullName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppTheme.primaryOrange,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (cart.cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.cartCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
                color: Colors.white,
                child: HomeSearchBar(
                  onDirectionTap: () =>
                      _locationService.openDirectionsInGoogleMaps(context),
                  controller: _homeSearchCtrl,
                  query: _homeSearchQuery,
                  onChanged: _onHomeSearchChanged,
                  onSubmitted: (v) {
                    _homeSearchDebounce?.cancel();
                    setState(() => _homeSearchQuery = v);
                  },
                  onClear: () {
                    _homeSearchCtrl.clear();
                    _homeSearchDebounce?.cancel();
                    setState(() => _homeSearchQuery = '');
                  },
                ),
              ),
            ),
          ),

          // Card jam buka (panel reservasi terintegrasi)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: OpeningHoursCard(
                isOpen: _isOpenNow(),
                dayLabel: _todayLabel(),
                openHour: _todayHours()['open']!,
                closeHour: _todayHours()['close']!,
              ),
            ),
          ),

          // Hasil Pencarian (muncul hanya jika ada query)
          if (_homeSearchQuery.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: FutureBuilder<List<MenuItem>>(
                  future: _popularFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Text('Gagal memuat hasil: ${snap.error}');
                    }

                    final all = snap.data ?? [];
                    final filtered = _filterByQuery(all, _homeSearchQuery);
                    final idr = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    );

                    if (filtered.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hasil Pencarian',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Tidak ada menu untuk "${_homeSearchQuery}".'),
                        ],
                      );
                    }

                    final items = filtered.take(8).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hasil Pencarian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: .72,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final it = items[i];
                            return HomeMenuCard(
                              title: it.name,
                              categoryName: it.category?.name ?? '',
                              priceText: idr.format(it.price),
                              imageUrl: it.imageUrl,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MenuDetailScreen(
                                      item: it,
                                      categoryName: it.category?.name ?? 'Menu',
                                    ),
                                  ),
                                );
                              },
                              onAddCart: () {
                                context.read<CartProvider>().addItem(
                                  id: it.id,
                                  name: it.name,
                                  imageUrl: it.imageUrl,
                                  priceInIDR: it.price,
                                  quantity: 1,
                                );
                                // Snackbar modern: item ditambah
                                _showModernSnackBar(
                                  message:
                                      '${it.name} ditambahkan ke keranjang',
                                  icon: Icons.check_circle,
                                  color: Colors.green.shade600,
                                  actionLabel: 'Lihat',
                                  onAction: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CartScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: const Text('Lihat semua di Menu'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MenuScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

          // Jika tidak mencari, tampilkan konten normal
          if (_homeSearchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: 'Promo Spesial'),
                    const SizedBox(height: 12),
                    PromoCarousel(banners: _banners),
                  ],
                ),
              ),
            ),

          if (_homeSearchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: 'Spesial Hari Ini'),
                    const SizedBox(height: 12),
                    FutureBuilder<List<MenuItem>>(
                      future: _popularFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snap.hasError) {
                          return Center(
                            child: Text('Gagal memuat menu: ${snap.error}'),
                          );
                        }
                        final items = (snap.data ?? []).take(6).toList();
                        if (items.isEmpty) {
                          return const Center(child: Text('Belum ada menu'));
                        }
                        final idr = NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        );
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: .72,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final it = items[i];
                            return HomeMenuCard(
                              title: it.name,
                              categoryName: it.category?.name ?? '',
                              priceText: idr.format(it.price),
                              imageUrl: it.imageUrl,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MenuDetailScreen(
                                      item: it,
                                      categoryName: it.category?.name ?? 'Menu',
                                    ),
                                  ),
                                );
                              },
                              onAddCart: () {
                                context.read<CartProvider>().addItem(
                                  id: it.id,
                                  name: it.name,
                                  imageUrl: it.imageUrl,
                                  priceInIDR: it.price,
                                  quantity: 1,
                                );
                                // Snackbar modern: item ditambah
                                _showModernSnackBar(
                                  message:
                                      '${it.name} ditambahkan ke keranjang',
                                  icon: Icons.check_circle,
                                  color: Colors.green.shade600,
                                  actionLabel: 'Lihat',
                                  onAction: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CartScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          if (_homeSearchQuery.isEmpty)
            SliverPadding(
              padding: EdgeInsets.only(
                // ruang ekstra = tinggi nav bar + safe area + margin kecil
                bottom:
                    kBottomNavigationBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    12, // sedikit lebih kecil
              ),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  // kurangi jarak atas dari 24 -> 8 agar lebih rapat
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: const VoucherBanner(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
