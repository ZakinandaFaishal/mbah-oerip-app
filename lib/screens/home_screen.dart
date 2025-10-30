import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../services/location_services.dart';
import '../models/menu_item.dart';
import '../theme.dart';
import 'cart_screen.dart';
import 'menu_detail_screen.dart';

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
      'subtitle': 'Khusus hari ini',
    },
  ];

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _popularFuture = _api.fetchAllMenuItems();
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
                  onDirectionTap: () {
                    _locationService.openDirectionsInGoogleMaps(context);
                  },
                ),
              ),
            ),
          ),

          // Card jam buka (panel reservasi sudah terintegrasi di dalam OpeningHoursCard)
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Ditambahkan ke keranjang',
                                  ),
                                  duration: const Duration(milliseconds: 800),
                                  action: SnackBarAction(
                                    label: 'Buka',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const CartScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: const VoucherBanner(),
            ),
          ),
        ],
      ),
    );
  }
}
