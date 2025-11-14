import 'package:flutter/material.dart';
import 'package:ingkung_mbah_oerip/providers/cart_provider.dart';
import 'package:ingkung_mbah_oerip/providers/orders_provider.dart';
import 'package:ingkung_mbah_oerip/screens/splash_screen.dart';
import 'package:ingkung_mbah_oerip/theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart'; // tambahkan

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  // INIT SUPABASE lebih awal (sebelum ada akses ke Supabase.instance)
  await ApiService.initialize();

  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// HAPUS variabel global ini (menyebabkan akses instance sebelum initialize):
// final supabase = Supabase.instance.client;

// Jika butuh, gunakan getter saja setelah initialize:
// SupabaseClient get supabase => Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ingkung Mbah Oerip',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
