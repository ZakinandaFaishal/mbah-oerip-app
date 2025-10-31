import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'vouchers_screen.dart';
import '../widgets/main/custom_bottom_nav_bar.dart';
import '../widgets/main/fab_home_button.dart';

class MainScreen extends StatefulWidget {
  final int
  initialIndex; // tab awal: 0=Home, 1=Menu, 2=Pesanan, 3=Voucher, 4=Profile
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // gunakan tab awal
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
      extendBody: true,
      resizeToAvoidBottomInset:
          false,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const MenuScreen(),
          const OrdersScreen(),
          const VouchersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        // Jika Home (0), set ke -1 agar semua menu non-aktif
        currentIndex: _selectedIndex == 0 ? -1 : _selectedIndex - 1,
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
