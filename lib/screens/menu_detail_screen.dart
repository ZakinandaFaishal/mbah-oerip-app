import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../widgets/price_display_widget.dart';
import '../widgets/time_converter_widget.dart';
import '/theme.dart';

class MenuDetailScreen extends StatelessWidget {
  final MenuItem item;
  const MenuDetailScreen({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,

      // 🔹 AppBar
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0.3,
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // 🔹 Tombol Pesan Sekarang (Bottom)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
          ],
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              // TODO: Tambahkan ke keranjang / langsung order
            },
            child: const Text("Pesan Sekarang"),
          ),
        ),
      ),

      // 🔹 Konten Utama
      body: ListView(
        children: [
          // Gambar menu
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: Image.network(
              item.imageUrl,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 260,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            ),
          ),

          // Detail isi
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama menu
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 6),

                // Harga
                Text(
                  "Rp ${item.price}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),

                const SizedBox(height: 16),

                // Deskripsi
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppTheme.textColor.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 24),

                // Separator lembut
                Divider(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  thickness: 1,
                ),

                const SizedBox(height: 14),

                // Info tambahan (optional)
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Waktu penyajian ± 10-15 menit",
                      style: TextStyle(
                        color: AppTheme.textColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
