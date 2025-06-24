import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodline/providers/order_provider.dart';
import 'package:woodline/providers/user_provider.dart';
import 'package:woodline/theme/app_colors.dart';
import 'package:woodline/widgets/app_button.dart';
import 'package:woodline/widgets/order_timeline.dart';
import 'package:woodline/widgets/order_product_item.dart';
import 'package:woodline/utils/app_utils.dart';
import 'package:woodline/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class OrderConfirmationScreenV2 extends StatefulWidget {
  final String orderId;
  final bool showSuccess;

  const OrderConfirmationScreenV2({
    Key? key,
    required this.orderId,
    this.showSuccess = true,
  }) : super(key: key);

  @override
  _OrderConfirmationScreenV2State createState() => _OrderConfirmationScreenV2State();
}

class _OrderConfirmationScreenV2State extends State<OrderConfirmationScreenV2> {
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
        'name': 'Handcrafted Wooden Coffee Table',
        'price': 129.99,
        'quantity': 1,
        'image': 'https://images.unsplash.com/photo-1555041463-a23f10c5ff3a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
                onPressed: () {
                  // TODO: Implement retry logic
                },
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
                _buildStatusCard(Theme.of(context), orderStatus, orderNumber, orderDate),
                
                const SizedBox(height: 24),
                
                // Order Timeline
                OrderTimeline(status: orderStatus),
                
                const SizedBox(height: 24),
                
                // Order Items
                Text('Order Items', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderProductItem(item: item),
                )).toList(),
                
                const SizedBox(height: 24),
                
                // Order Summary
                _buildOrderSummary(Theme.of(context), totalAmount, items.length),
                
                const SizedBox(height: 24),
                
                // Shipping Information
                _buildShippingInfo(
                  Theme.of(context), 
                  shippingAddress, 
                  paymentMethod, 
                  estimatedDelivery,
                ),
                
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order has been placed successfully',
                        style: Theme.of(context).textTheme.bodyMedium,
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

  // Build status card with order confirmation details
  Widget _buildStatusCard(ThemeData theme, String status, String orderNumber, String orderDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Order Confirmed',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Order Number', orderNumber, theme),
          const SizedBox(height: 8),
          _buildInfoRow('Date', orderDate, theme),
          const SizedBox(height: 8),
          _buildInfoRow('Status', status.toUpperCase(), theme, isStatus: true),
        ],
      ),
    );
  }

  // Build info row for order details
  Widget _buildInfoRow(String label, String value, ThemeData theme, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  // Build order summary card
  Widget _buildOrderSummary(ThemeData theme, double totalAmount, int itemCount) {
    final textTheme = theme.textTheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', '\$${totalAmount.toStringAsFixed(2)}', theme),
          const Divider(height: 24),
          _buildSummaryRow('Shipping', 'Free', theme),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total',
            '\$${totalAmount.toStringAsFixed(2)}',
            theme,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  // Build summary row for order summary
  Widget _buildSummaryRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Build shipping information card
  Widget _buildShippingInfo(
    ThemeData theme,
    String address,
    String paymentMethod,
    String deliveryDate,
  ) {
    final textTheme = theme.textTheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Information',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoWithIcon(
            Icons.location_on_outlined,
            'Shipping Address',
            address,
            theme,
          ),
          const SizedBox(height: 16),
          _buildInfoWithIcon(
            Icons.payment_outlined,
            'Payment Method',
            paymentMethod,
            theme,
          ),
          const SizedBox(height: 16),
          _buildInfoWithIcon(
            Icons.local_shipping_outlined,
            'Estimated Delivery',
            'Arrives by $deliveryDate',
            theme,
          ),
        ],
      ),
    );
  }

  // Build info row with icon
  Widget _buildInfoWithIcon(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
