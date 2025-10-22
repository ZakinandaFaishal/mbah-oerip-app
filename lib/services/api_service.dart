import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

class ApiService {
  // GANTI DENGAN URL JSON ANDA!
  final String _menuApiUrl = "https://my-json-server.typicode.com/zakinandafaishal/ingkung-api/db";

  Future<Map<String, List<MenuItem>>> fetchMenu() async {
    try {
      final response = await http.get(Uri.parse(_menuApiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> categories = data['categories'];
        
        Map<String, List<MenuItem>> menuData = {};

        for (var category in categories) {
          String categoryName = category['name'];
          List<dynamic> items = category['items'];
          List<MenuItem> menuItems = items.map((item) => MenuItem.fromJson(item)).toList();
          menuData[categoryName] = menuItems;
        }
        return menuData;
      } else {
        throw Exception('Gagal memuat menu: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}