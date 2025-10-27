import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ingkung_mbah_oerip/providers/auth_provider.dart';
import 'package:ingkung_mbah_oerip/screens/login_screen.dart';
import 'package:ingkung_mbah_oerip/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('session');
  await Hive.openBox('feedback');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Ingkung Mbah Oerip',
        theme: ThemeData(
        useMaterial3: true, // Tambahkan agar konsisten UI baru
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        primaryColor: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),

        appBarTheme: const AppBarTheme(
          elevation: 0.5,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.brown),
          floatingLabelStyle: const TextStyle(color: Colors.brown),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.brown, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        fontFamily: 'Poppins',
      ),

        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }
}