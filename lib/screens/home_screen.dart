import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fullName = authProvider.currentUserData?['fullName'] ?? "Pelanggan";

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== GREETING =====
            Text(
              "Hai, $fullName 👋",
              style: AppTheme.headingStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Mau pesan apa hari ini?",
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 15,
                color: AppTheme.baseTextColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // ===== PROMO BANNER =====
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Image.network(
                    "https://i.ibb.co/L5hB6M7/promo-banner.jpg",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      "Diskon Hingga 30%\nNikmati Ingkung Terbaik!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ===== TITLE Rekomendasi =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Menu Rekomendasi",
                  style: AppTheme.headingStyle.copyWith(
                    fontSize: 19,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  "Lihat Semua",
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== CARD LIST =====
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  RecommendationCard(
                    image: "https://i.ibb.co/F8zGzQ2/ingkung-original.jpg",
                    title: "Ingkung Original",
                    price: "Rp 95.000",
                  ),
                  RecommendationCard(
                    image: "https://i.ibb.co/z5pD1V6/ingkung-bakar.jpg",
                    title: "Ingkung Bakar",
                    price: "Rp 105.000",
                  ),
                  RecommendationCard(
                    image: "https://i.ibb.co/yQn7qfB/es-jeruk.jpg",
                    title: "Es Jeruk Segar",
                    price: "Rp 8.000",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
//  RECOMMENDATION CARD
// ===================================================================
class RecommendationCard extends StatelessWidget {
  final String image;
  final String title;
  final String price;

  const RecommendationCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: AppTheme.accentColor.withOpacity(0.1),
        onTap: () {},
        child: Card(
          elevation: 4,
          shadowColor: AppTheme.accentColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  image,
                  height: 115,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.baseTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      price,
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Pesan"),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
