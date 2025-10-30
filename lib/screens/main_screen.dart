import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'vouchers_screen.dart';
import '../widgets/main/custom_bottom_nav_bar.dart';
import '../widgets/main/fab_home_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0 = Home (FAB tengah)

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const MenuScreen(),
      const OrdersScreen(),
      const VouchersScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index + 1; // Menu=1, Pesanan=2, dst
    });
  }

  void _onFABPressed() {
    setState(() {
      _selectedIndex = 0; // Home
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // penting agar area notch/celah benar-benar transparan
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex == 0 ? 0 : _selectedIndex - 1,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FABHomeButton(
        onPressed: _onFABPressed,
        isActive: _selectedIndex == 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
