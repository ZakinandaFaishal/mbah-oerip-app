import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../models/menu_item.dart';
import '../theme.dart';
import '../widgets/home/header_sliver_app_bar.dart';
import '../widgets/home/opening_hours_card.dart';
import '../widgets/home/promo_carousel.dart';
import '../widgets/home/voucher_banner.dart';
import '../widgets/home/search_results_section.dart';
import '../widgets/home/specials_grid_section.dart';
import '../widgets/home/section_title.dart';
import '../utils/open_hours.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../utils/snackbar_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  late Future<List<MenuItem>> _popularFuture;

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
    OpenHours.ensureInit();
    _popularFuture = _api.fetchAllMenuItems();
  }

  static const String _whatsAppNumber = '+62821388788657';

  Future<void> _openWhatsApp(BuildContext context) async {
    try {
      // format untuk wa.me: gunakan angka tanpa + dan tanpa spasi
      final digits = _whatsAppNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final uri = Uri.parse(
        'https://wa.me/$digits?text=${Uri.encodeComponent('Halo, saya mau pesan / tanya menu')}',
      );
      final ok = await canLaunchUrl(uri);
      if (!ok) throw 'Tidak bisa membuka WhatsApp';
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      showModernSnackBar(
        context,
        message: 'Gagal membuka WhatsApp: ${e.toString()}',
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fullName = auth.currentUserData?['fullName'] ?? 'Pelanggan';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          HeaderSliverAppBar(
            fullName: fullName,
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
            onDirectionTap: () {
              // arahkan via LocationService jika diperlukan
              // dipanggil dari HomeSearchBar
            },
          ),

          // Card jam buka
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: OpeningHoursCard(
                isOpen: OpenHours.isOpenNow(),
                dayLabel: OpenHours.todayLabel(),
                openHour: OpenHours.todayHours()['open']!,
                closeHour: OpenHours.todayHours()['close']!,
              ),
            ),
          ),

          // Hasil Pencarian
          if (_homeSearchQuery.isNotEmpty)
            SliverToBoxAdapter(
              child: SearchResultsSection(
                itemsFuture: _popularFuture,
                query: _homeSearchQuery,
              ),
            ),

          // Konten normal saat tidak mencari
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
              child: SpecialsGridSection(itemsFuture: _popularFuture),
            ),

          // Kontak WhatsApp rumah makan
          if (_homeSearchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.chat,
                      color: Colors.green.shade700,
                      size: 34,
                    ),
                    title: const Text('Kontak WhatsApp'),
                    subtitle: Text(_whatsAppNumber),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(context),
                      icon: const Icon(Icons.chat_bubble),
                      label: const Text('Chat'),
                    ),
                  ),
                ),
              ),
            ),

          if (_homeSearchQuery.isEmpty)
            SliverPadding(
              padding: EdgeInsets.only(
                bottom:
                    kBottomNavigationBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    12,
              ),
              sliver: SliverToBoxAdapter(
                child: Padding(
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
