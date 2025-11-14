import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart'; 

const String _supabaseUrl = 'https://wmfwmgnjekmguivzmdps.supabase.co';
const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtZndtZ25qZWttZ3VpdnptZHBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MTgzNDcsImV4cCI6MjA3ODQ5NDM0N30.8QCbEhTbiy0PqVjD-Se_LVrMELh-m9soYTiaNZ5bkDk';

class ApiService {

  // FUNGSI INITIALIZE STATIS
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  // GETTER UNTUK MENGAKSES CLIENT
  SupabaseClient get client => Supabase.instance.client;

  // FUNGSI PENGAMBILAN DATA MENU (Flat list)
  Future<List<MenuItem>> fetchAllMenuItems() async {
    try {
      // Ambil data menggunakan 'client' getter
      final response = await client
          .from('menu_items')
          .select('*, category:categories(*)');

      final List<dynamic> data = response;
      return data.map((item) => MenuItem.fromJson(item)).toList();
      
    } catch (e) {
      debugPrint("Error fetching menu: $e");
      throw Exception('Gagal memuat data menu dari Supabase');
    }
  }
}