import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodline/providers/order_provider.dart';
import 'package:woodline/providers/user_provider.dart';
import 'package:woodline/theme/app_theme.dart';
import 'package:woodline/widgets/app_button.dart';
import 'package:woodline/widgets/order_timeline.dart';
import 'package:woodline/widgets/order_product_item.dart';
import 'package:woodline/utils/app_utils.dart';
import 'package:woodline/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  final bool showSuccess;

  const OrderConfirmationScreen({
    Key? key,
    required this.orderId,
    this.showSuccess = true,
  }) : super(key: key);

  @override
  _OrderConfirmationScreenState createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isLoading = true;
  bool _showSuccess = true;
  String? _error;
  Map<String, dynamic>? _orderData;
  
  // Mock order data - replace with actual data from provider
  final Map<String, dynamic> _mockOrderData = {
    'id': 'ORD-123456',
    'status': 'processing',
    'createdAt': DateTime.now(),
    'totalAmount': 129.99,
    'items': [
      {
        'id': '1',
        'name': 'Wooden Coffee Table',
        'price': 129.99,
        'quantity': 1,
        'image': 'https://via.placeholder.com/80',
      },
    ],
    'shippingAddress': '123 Main St, Apt 4B\nNew York, NY 10001',
    'paymentMethod': 'Credit Card',
    'estimatedDelivery': DateTime.now().add(const Duration(days: 5)),
  };

  @override
  void initState() {
    super.initState();
    // Use mock data for now
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _orderData = _mockOrderData;
          _isLoading = false;
        });
      }
    });
    
    // Auto-hide success animation after 3 seconds
    if (widget.showSuccess) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
          });
        }
      });
    }
  }

  Future<void> _loadOrderDetails() async {
    try {
      final orderProvider = context.read<OrderProvider>();
      final order = await orderProvider.getOrderById(widget.orderId);
      
      if (order != null && mounted) {
        setState(() {
          _orderData = order.toMap();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Order not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load order details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    if (_isLoading || _orderData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Confirmation'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Confirmation'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    final order = _orderData!;
    final orderStatus = order['status'] as String;
    final orderNumber = order['id'] as String;
    final orderDate = DateFormat('MMM d, y • hh:mm a').format(order['createdAt'] as DateTime);
    final totalAmount = order['totalAmount'] as double;
    final items = order['items'] as List<dynamic>;
    final shippingAddress = order['shippingAddress'] as String;
    final paymentMethod = order['paymentMethod'] as String;
    final estimatedDelivery = DateFormat('MMM d, y').format(order['estimatedDelivery'] as DateTime);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Status Card
                _buildStatusCard(theme, orderStatus, orderNumber, orderDate),
                
                const SizedBox(height: 24),
                
                // Order Timeline
                OrderTimeline(status: orderStatus),
                
                const SizedBox(height: 24),
                
                // Order Items
                Text('Order Items', style: textTheme.titleLarge),
                const SizedBox(height: 12),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderProductItem(item: item),
                )).toList(),
                
                const SizedBox(height: 24),
                
                // Order Summary
                _buildOrderSummary(theme, totalAmount, items.length),
                
                const SizedBox(height: 24),
                
                // Shipping Information
                _buildShippingInfo(theme, shippingAddress, paymentMethod, estimatedDelivery),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        onPressed: () {
                          // TODO: Navigate to order tracking
                        },
                        text: 'Track Order',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        onPressed: () {
                          // TODO: Navigate to home
                        },
                        text: 'Continue Shopping',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Success Animation Overlay
          if (_showSuccess && widget.showSuccess)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/animations/success.json',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Order Placed!',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order has been placed successfully',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

    final orderNumber = _orderData?['id'] ?? '';
    final orderDate = _orderData?['createdAt'] != null
        ? DateFormat('MMMM d, y hh:mm a').format(
            (_orderData?['createdAt'] as Timestamp).toDate(),
          )
        : '';
    final orderStatus = _orderData?['status'] ?? 'pending';
    final totalAmount = _orderData?['totalAmount']?.toDouble() ?? 0.0;
    final paymentStatus = _orderData?['isPaid'] == true ? 'Paid' : 'Pending';
    final paymentMethod = _orderData?['paymentMethod'] ?? 'Cash on Delivery';
    final items = _orderData?['items'] as List<dynamic>? ?? [];
    final shippingAddress = _orderData?['shippingAddress'] ?? 'Not specified';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Message
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.green.shade100, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Thank You for Your Order!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your order has been placed successfully',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OrderStatusChip(status: orderStatus),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order Summary
            Text(
              'Order Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Order Number', orderNumber),
                    const Divider(),
                    _buildInfoRow('Order Date', orderDate),
                    const Divider(),
                    _buildInfoRow('Status', orderStatus.toUpperCase()),
                    const Divider(),
                    _buildInfoRow('Payment', '$paymentStatus (${paymentMethod.toUpperCase()})'),
                    const Divider(),
                    _buildInfoRow('Total', '\$${totalAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order Items
            Text(
              'Order Items (${items.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildOrderItem(item)).toList(),
            const SizedBox(height: 24),

            // Shipping Information
            Text(
              'Shipping Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Address',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shippingAddress,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Next Steps
            Text(
              'What\'s Next?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildNextStep(
                      icon: Icons.email_outlined,
                      title: 'Order Confirmation',
                      description: 'We\'ve sent an order confirmation email with details and tracking information.',
                    ),
                    const Divider(),
                    _buildNextStep(
                      icon: Icons.schedule_outlined,
                      title: 'Order Processing',
                      description: 'Your order is being processed and will be shipped soon.',
                    ),
                    const Divider(),
                    _buildNextStep(
                      icon: Icons.track_changes_outlined,
                      title: 'Track Your Order',
                      description: 'You can track your order status in the app or using the tracking number provided.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            if (!isSeller) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to order tracking
                    Navigator.pushReplacementNamed(
                      context,
                      '/orders',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'VIEW MY ORDERS',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to home
                    Navigator.pushReplacementNamed(
                      context,
                      '/',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: theme.primaryColor),
                  ),
                  child: Text(
                    'CONTINUE SHOPPING',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: item['productImage'] != null
            ? Image.network(
                item['productImage'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image, size: 40),
        title: Text(item['productName'] ?? 'Product'),
        subtitle: Text('Qty: ${item['quantity'] ?? 1}'),
        trailing: Text(
          '\$${(item['price'] * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNextStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
