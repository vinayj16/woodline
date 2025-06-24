import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodline/models/order_model.dart';
import 'package:woodline/providers/order_provider.dart';
import 'package:woodline/providers/user_provider.dart';
import 'package:woodline/utils/app_utils.dart';
import 'package:woodline/constants/app_constants.dart';
import 'package:woodline/widgets/address_form.dart';

class CheckoutScreen extends StatefulWidget {
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String sellerId;

  const CheckoutScreen({
    Key? key,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.sellerId,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  String _selectedPaymentMethod = 'cod';
  final List<String> _paymentMethods = [
    'cod',
    'card',
    'paypal',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.items.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.user == null) {
      if (mounted) {
        AppUtils.showErrorSnackBar(context, message: 'Please sign in to place an order');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderProvider = context.read<OrderProvider>();
      
      final order = OrderModel(
        id: '', // Will be set by Firestore
        customerId: userProvider.user!.id,
        sellerId: widget.sellerId,
        items: widget.items,
        subtotal: widget.subtotal,
        shippingFee: widget.shippingFee,
        totalAmount: widget.totalAmount,
        status: 'pending',
        shippingAddress: _addressController.text.trim(),
        customerNotes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPaid: _selectedPaymentMethod != 'cod',
        paymentMethod: _selectedPaymentMethod,
      );

      final createdOrder = await orderProvider.createOrder(order);
      
      if (createdOrder != null && mounted) {
        // Navigate to order confirmation screen
        Navigator.pushReplacementNamed(
          context, 
          '/order-confirmation',
          arguments: {'orderId': createdOrder.id},
        );
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          message: 'Failed to place order: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    
                    // Shipping Address
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AddressForm(controller: _addressController),
                    const SizedBox(height: 24),
                    
                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._paymentMethods.map((method) {
                      return RadioListTile<String>(
                        title: Text(
                          _getPaymentMethodName(method),
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          _getPaymentMethodDescription(method),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        value: method,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          }
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    
                    // Order Notes
                    const Text(
                      'Order Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Special instructions for your order...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'PLACE ORDER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            
            // Order Items
            ...widget.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: item.productImage != null
                          ? DecorationImage(
                              image: NetworkImage(item.productImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.productImage == null
                        ? const Icon(Icons.photo, size: 30, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Item Total
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            const Divider(height: 24),
            
            // Order Totals
            _buildOrderTotalRow('Subtotal', '\$${widget.subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildOrderTotalRow('Shipping', '\$${widget.shippingFee.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildOrderTotalRow(
              'Total',
              '\$${widget.totalAmount.toStringAsFixed(2)}',
              isBold: true,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTotalRow(String label, String value, 
      {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isLarge ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cod':
        return 'Cash on Delivery';
      case 'card':
        return 'Credit/Debit Card';
      case 'paypal':
        return 'PayPal';
      default:
        return method;
    }
  }

  String _getPaymentMethodDescription(String method) {
    switch (method) {
      case 'cod':
        return 'Pay when you receive your order';
      case 'card':
        return 'Pay with your credit or debit card';
      case 'paypal':
        return 'Pay with your PayPal account';
      default:
        return '';
    }
  }
}
