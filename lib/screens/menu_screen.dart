import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/menu_item.dart';
import '/theme.dart';
import 'menu_detail_screen.dart';
import 'package:intl/intl.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String selectedCategory = "Semua";

  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite.withOpacity(0.97),

      // APP BAR CUSTOM
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(105),
        child: SafeArea(
          child: Column(
            children: [
              Text(
                "Ingkung Eco Mbah Oerip Progowati",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                "Jl. Semarang - Yogyakarta",
                style: TextStyle(
                  color: AppTheme.accentColor.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      // BODY
      body: FutureBuilder<List<MenuItem>>(
        future: _apiService.fetchAllMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final allMenuItems = snapshot.data ?? [];

          // Ambil semua nama kategori unik dari daftar menu
          final allCategoryNames = allMenuItems.map((item) => item.category.name).toSet().toList();
          final categories = ["Semua", ...allCategoryNames];

          // Logika filter yang baru dan benar
          final filteredMenuItems = selectedCategory == "Semua"
              ? allMenuItems // Jika "Semua", tampilkan semua
              : allMenuItems.where((item) => item.category.name == selectedCategory).toList(); // Filter berdasarkan nama kategori

          return Column(
            children: [
              // CATEGORY TAB (Kode ini sudah benar)
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;

                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.backgroundWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // GRID MENU (Logika onTap diperbaiki)
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredMenuItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76, // Sesuaikan rasio agar pas
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredMenuItems[index];
                    return GestureDetector(
                      onTap: () {
                        // 4. LOGIKA NAVIGASI DIPERBAIKI
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenuDetailScreen(
                              item: item,
                              // Ambil nama kategori langsung dari item
                              categoryName: item.category.name,
                            ),
                          ),
                        );
                        // ---- AKHIR PERBAIKAN ----
                      },
                      child: Column(
                        // --- GRID ---
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppTheme.primaryColor,
                              )),
                          Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(item.price),
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

