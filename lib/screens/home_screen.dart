import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final ApiService _api = ApiService();

  late Future<List<MenuItem>> _popularFuture;
  int _currentBanner = 0;

  final List<Map<String, String>> _banners = const [
    {
      'image':
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1600&auto=format&fit=crop',
      'title': 'Diskon 30%',
      'subtitle': 'Untuk pembelian pertama',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1604909052743-86e84eaf9a1c?q=80&w=1600&auto=format&fit=crop',
      'title': 'Beli 2 Gratis 1',
      'subtitle': 'Menu pilihan spesial',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1561758033-d89a9ad46330?q=80&w=1600&auto=format&fit=crop',
      'title': 'Gratis Ongkir',
      'subtitle': 'Khusus hari ini',
    },
  ];

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _popularFuture = _api
        .fetchAllMenuItems(); // ambil semua, nanti ambil 6 teratas
  }

  // Jam operasional dinamis per hari
  Map<String, int> _todayHours() {
    final loc = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime.now(loc);

    // Contoh jadwal (bisa ubah per hari)
    final schedule = <int, Map<String, int>>{
      1: {'open': 10, 'close': 21}, // Senin
      2: {'open': 10, 'close': 21},
      3: {'open': 10, 'close': 21},
      4: {'open': 10, 'close': 21},
      5: {'open': 10, 'close': 22}, // Jumat
      6: {'open': 9, 'close': 22}, // Sabtu
      7: {'open': 9, 'close': 21}, // Minggu
    };

    return schedule[now.weekday] ?? {'open': 10, 'close': 21};
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
                child: _SearchBar(
                  onDirectionTap: () {
                    _locationService.openDirectionsInGoogleMaps(context);
                  },
                ),
              ),
            ),
          ),

          // Jam operasional
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _OpeningHoursCard(
                isOpen: _isOpenNow(),
                dayLabel: _todayLabel(),
                openHour: _todayHours()['open']!,
                closeHour: _todayHours()['close']!,
              ),
            ),
          ),

          // Carousel Promo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Promo Spesial'),
                  const SizedBox(height: 12),
                  _banners.isEmpty
                      ? Container(
                          height: 180,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Tidak ada promo'),
                        )
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: 180,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: .9,
                            onPageChanged: (i, _) =>
                                setState(() => _currentBanner = i),
                          ),
                          items: _banners.map((b) {
                            return _PromoCard(
                              imageUrl: b['image']!,
                              title: b['title']!,
                              subtitle: b['subtitle']!,
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_banners.length, (i) {
                      final active = _currentBanner == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.primaryOrange
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Menu populer / spesial hari ini
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Spesial Hari Ini'),
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
                          return _MenuCard(
                            title: it.name,
                            categoryName:
                                it.category?.name ??
                                '', // Tambahan: tampilkan kategori
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

          // Banner voucher
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: _VoucherBanner(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onDirectionTap;
  const _SearchBar({required this.onDirectionTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Cari menu favorit…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
            ),
            onTap: () {
              // Arahkan ke halaman Menu jika ingin
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
            },
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onDirectionTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _OpeningHoursCard extends StatelessWidget {
  final bool isOpen;
  final String dayLabel;
  final int openHour;
  final int closeHour;

  const _OpeningHoursCard({
    required this.isOpen,
    required this.dayLabel,
    required this.openHour,
    required this.closeHour,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOpen ? Colors.green : Colors.red;
    final now = DateFormat('HH:mm').format(DateTime.now());
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOpen ? Icons.access_time_filled : Icons.lock_clock,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Buka $dayLabel',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${openHour.toString().padLeft(2, '0')}:00 - ${closeHour.toString().padLeft(2, '0')}:00 WIB',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sekarang: $now WIB',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOpen ? 'Buka' : 'Tutup',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const _PromoCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(.55), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String priceText;
  final String? categoryName; // Tambahan: kategori
  final VoidCallback onTap;
  final VoidCallback? onAddCart;

  const _MenuCard({
    required this.imageUrl,
    required this.title,
    required this.priceText,
    required this.onTap,
    this.categoryName, // Tambahan
    this.onAddCart,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if ((widget.categoryName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.categoryName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.priceText,
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (widget.onAddCart != null)
                          GestureDetector(
                            onTap: widget.onAddCart,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withOpacity(.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _VoucherBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          // Background image
          Image.network(
            'https://images.unsplash.com/photo-1556745753-b2904692b3cd?q=80&w=1600&auto=format&fit=crop',
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Overlay
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(.6), Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          // Text
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Gunakan Voucher',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Potongan hingga 30% untuk menu favoritmu',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryOrange,
                    ),
                    onPressed: () {},
                    child: const Text('Pakai'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
