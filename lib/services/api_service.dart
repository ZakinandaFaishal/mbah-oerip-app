import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

Future<List<Zaki>> fetchProducts() async {
  final response = await http.get(
    Uri.parse('https://monitoringweb.decoratics.id/api/mbah-oerip/menu'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => Zaki.fromJson(item)).toList();
  } else {
    throw Exception('Gagal memuat data dari server');
  }
}