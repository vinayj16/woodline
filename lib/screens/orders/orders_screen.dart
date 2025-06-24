import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodline/providers/order_provider.dart';
import 'package:woodline/providers/user_provider.dart';
import 'package:woodline/theme/app_colors.dart';
import 'package:woodline/widgets/order_card.dart';
import 'package:woodline/widgets/empty_state_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _tabs = ['All', 'Pending', 'Processing', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final userProvider = context.read<UserProvider>();
    final orderProvider = context.read<OrderProvider>();
    
    if (userProvider.user != null) {
      orderProvider.fetchOrders(userId: userProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    orderProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              final filteredOrders = _filterOrdersByStatus(
                orderProvider.orders,
                tab,
              );

              if (filteredOrders.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.shopping_bag_outlined,
                  title: 'No ${tab.toLowerCase()} orders',
                  subtitle: 'Your ${tab.toLowerCase()} orders will appear here',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadOrders(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: OrderCard(order: filteredOrders[index]),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  List<dynamic> _filterOrdersByStatus(List<dynamic> orders, String status) {
    if (status == 'All') return orders;
    
    switch (status) {
      case 'Pending':
        return orders.where((order) => order.status == 'pending').toList();
      case 'Processing':
        return orders.where((order) => 
          ['confirmed', 'processing', 'shipped'].contains(order.status)
        ).toList();
      case 'Completed':
        return orders.where((order) => 
          ['delivered', 'cancelled'].contains(order.status)
        ).toList();
      default:
        return orders;
    }
  }
}