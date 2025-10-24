import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Produk')),
      body: FutureBuilder<List<Zaki>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data'));
          }
          final products = snapshot.data ?? [];
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final zaki = products[index];
              return ExpansionTile(
                title: Text(zaki.name),
                children: zaki.menuItems.map((item) {
                  return ListTile(
                    leading: Image.network(
                      item.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    trailing: Text('Rp ${item.price}'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
