import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fullName = authProvider.currentUserData?['fullName'] ?? "Pelanggan";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120.0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Hai, $fullName!',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                color: Colors.brown[50],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Promo Card
                  const Text(
                    "Promo Spesial Untukmu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage("https://i.ibb.co/L5hB6M7/promo-banner.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Menu Rekomendasi
                  const Text(
                    "Rekomendasi Kami",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
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
          ),
        ],
      ),
    );
  }
}

// Widget terpisah untuk kartu rekomendasi
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
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 1.5,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                price,
                style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}