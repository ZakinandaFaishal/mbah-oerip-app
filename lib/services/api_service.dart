import 'dart:convert';
import 'package:http/http.dart' as http;
// Pastikan file ini berisi class Menu (Kategori) dan MenuItem (Produk)
import '../models/menu_item.dart'; 

class ApiService {
  // Gunakan ini sebagai base URL Anda
  final String _baseApiUrl = "https://monitoringweb.decoratics.id/api/mbah-oerip";
  
  Future<List<MenuItem>> fetchAllMenuItems() async {
    // Panggil endpoint /menu
    final response = await http.get(Uri.parse("$_baseApiUrl/menu"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Parsing data sebagai List<MenuItem> (Produk)
      return data.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data menu');
    }
  }
}

