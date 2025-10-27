import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

// Future<List<Menu>> fetchProducts() async {
//   final response = await http.get(
//     Uri.parse('https://monitoringweb.decoratics.id/api/mbah-oerip/menu'),
//     // Uri.parse('https://monitoringweb.decoratics.id/api/mbah-oerip/menu'),

//   );

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body);
//     return data.map((item) => Menu.fromJson(item)).toList();
//   } else {
//     throw Exception('Gagal memuat data dari server');
//   }
// }

class ApiService {
  // final String _menuApiUrl = "http://127.0.0.1/:8000/api/menu";
  final String _menuApiUrl = "https://monitoringweb.decoratics.id/api/mbah-oerip/menu";

  Future<List<Menu>> fetchAllMenuItems() async {
    final response = await http.get(Uri.parse(_menuApiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Menu.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data dari server');
    }
  }
  
}