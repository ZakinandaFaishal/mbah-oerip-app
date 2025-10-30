import 'package:flutter/material.dart';
import 'package:ingkung_mbah_oerip/providers/cart_provider.dart';
import 'package:ingkung_mbah_oerip/providers/orders_provider.dart';
import 'package:ingkung_mbah_oerip/screens/splash_screen.dart';
import 'package:ingkung_mbah_oerip/theme.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Hive.initFlutter();

  // Buka semua box yang akan digunakan di sini
  await Hive.openBox('users');
  await Hive.openBox('session');
  await Hive.openBox('feedback');


  runApp(
    MultiProvider(
      providers: [
        // AuthProvider sekarang aman untuk diinisialisasi
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

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
