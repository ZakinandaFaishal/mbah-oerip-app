import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';
import '../theme.dart';
import '../widgets/orders/unpaid_tab.dart';
import '../widgets/orders/history_tab.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final orders = context.watch<OrdersProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan'),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryOrange,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppTheme.primaryOrange,
            tabs: [
              Tab(text: 'Belum Dibayar'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const UnpaidTab(),
            orders.loading
                ? const Center(child: CircularProgressIndicator())
                : const HistoryTab(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
