import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/login_screen.dart';
import '../../models/menu_item.dart';
import '../../providers/cart_provider.dart';
import '../../screens/cart_screen.dart';
import '../../screens/menu_detail_screen.dart';
import 'home_menu_card.dart';
import 'section_title.dart';
import '../../utils/snackbar_utils.dart';

class SpecialsGridSection extends StatelessWidget {
  const SpecialsGridSection({super.key, required this.itemsFuture});

  final Future<List<MenuItem>> itemsFuture;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Spesial Hari Ini'),
          const SizedBox(height: 12),
          FutureBuilder<List<MenuItem>>(
            future: itemsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snap.hasError) {
                return Center(child: Text('Gagal memuat menu: ${snap.error}'));
              }
              final items = (snap.data ?? []).take(6).toList();
              if (items.isEmpty) {
                return const Center(child: Text('Belum ada menu'));
              }
              final idr = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .72,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final it = items[i];
                  return HomeMenuCard(
                    title: it.name,
                    categoryName: it.category.name,
                    priceText: idr.format(it.price),
                    imageUrl: it.imageUrl,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MenuDetailScreen(
                            item: it,
                            categoryName: it.category.name,
                          ),
                        ),
                      );
                    },
                    onAddCart: () {
                      final auth = context.read<AuthProvider>();
                      if (!auth.isLoggedIn) {
                        showDialog(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: const Text('Butuh Login'),
                            content: const Text(
                              'Silakan login atau daftar untuk menambahkan item ke keranjang.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dCtx).pop(),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dCtx).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      context.read<CartProvider>().addItem(
                        id: it.id,
                        name: it.name,
                        imageUrl: it.imageUrl,
                        priceInIDR: it.price,
                        quantity: 1,
                      );
                      showModernSnackBar(
                        context,
                        message: '${it.name} Ditambahkan ke keranjang',
                        icon: Icons.add_shopping_cart,
                        color: Colors.green.shade600,
                        actionLabel: 'Lihat',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
