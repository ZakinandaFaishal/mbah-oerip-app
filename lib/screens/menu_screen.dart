import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<Map<String, List<MenuItem>>> _menuFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _menuFuture = _apiService.fetchMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Menu"),
      ),
      body: FutureBuilder<Map<String, List<MenuItem>>>(
        future: _menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            final menuData = snapshot.data!;
            final categories = menuData.keys.toList();
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final items = menuData[category]!;
                return ExpansionTile(
                  title: Text(
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  initiallyExpanded: true, // Biar semua kategori terbuka
                  children: items.map((item) => _buildMenuItem(item)).toList(),
                );
              },
            );
          } else {
            return const Center(child: Text("Tidak ada data menu"));
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    // Format harga
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedPrice = currencyFormatter.format(item.price);

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          item.imageUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.fastfood, size: 50, color: Colors.grey),
        ),
      ),
      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(
        formattedPrice,
        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        // Aksi saat item menu diklik (misal: tambah ke keranjang)
      },
    );
  }
}