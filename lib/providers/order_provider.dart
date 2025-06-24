import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:woodline/models/order_model.dart';
import 'package:woodline/constants/app_constants.dart';
import 'package:woodline/utils/app_utils.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  String? _lastDocumentId;
  bool _hasMore = true;
  final int _pageSize = 10;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Fetch orders with pagination
  Future<void> fetchOrders({
    String? userId,
    String? sellerId,
    String? status,
    bool loadMore = false,
  }) async {
    if ((!loadMore && _isLoading) || (loadMore && (!_hasMore || _isLoading))) {
      return;
    }

    _isLoading = true;
    _error = null;
    
    if (!loadMore) {
      _orders = [];
      _lastDocumentId = null;
      _hasMore = true;
    }
    
    notifyListeners();

    try {
      Query query = _firestore
          .collection(AppConstants.ordersCollection)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      // Apply filters
      if (userId != null) {
        query = query.where('customerId', isEqualTo: userId);
      }
      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      // Apply pagination
      if (loadMore && _lastDocumentId != null) {
        final lastDoc = await _firestore
            .collection(AppConstants.ordersCollection)
            .doc(_lastDocumentId)
            .get();
        query = query.startAfterDocument(lastDoc);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        final newOrders = querySnapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();

        if (loadMore) {
          _orders.addAll(newOrders);
        } else {
          _orders = newOrders;
        }

        _lastDocumentId = querySnapshot.docs.last.id;
        _hasMore = newOrders.length == _pageSize;
      }
    } catch (e) {
      _error = 'Failed to load orders';
      if (kDebugMode) {
        print('Error fetching orders: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting order: $e');
      }
      rethrow;
    }
  }

  // Create a new order
  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final docRef = await _firestore
          .collection(AppConstants.ordersCollection)
          .add(order.toMap());

      // Get the created order with ID
      final doc = await docRef.get();
      final createdOrder = OrderModel.fromFirestore(doc);
      
      // Add to local list
      _orders.insert(0, createdOrder);
      
      return createdOrder;
    } catch (e) {
      _error = 'Failed to create order';
      if (kDebugMode) {
        print('Error creating order: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
    String? sellerNotes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (sellerNotes != null) 'sellerNotes': sellerNotes,
      };

      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update(updateData);

      // Update local order
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: status,
          trackingNumber: trackingNumber ?? _orders[index].trackingNumber,
          sellerNotes: sellerNotes ?? _orders[index].sellerNotes,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _error = 'Failed to update order status';
      if (kDebugMode) {
        print('Error updating order status: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update({
            'status': 'cancelled',
            'sellerNotes': reason != null
                ? 'Cancelled: $reason'
                : 'Order cancelled by customer',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local order
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: 'cancelled',
          sellerNotes: reason != null
              ? 'Cancelled: $reason'
              : 'Order cancelled by customer',
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _error = 'Failed to cancel order';
      if (kDebugMode) {
        print('Error cancelling order: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark order as paid
  Future<void> markAsPaid(String orderId, String paymentMethod, String paymentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update({
            'isPaid': true,
            'paymentMethod': paymentMethod,
            'paymentId': paymentId,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local order
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          isPaid: true,
          paymentMethod: paymentMethod,
          paymentId: paymentId,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _error = 'Failed to update payment status';
      if (kDebugMode) {
        print('Error updating payment status: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get orders count by status
  Future<Map<String, int>> getOrdersCountByStatus(String userId, {bool isSeller = false}) async {
    try {
      final field = isSeller ? 'sellerId' : 'customerId';
      
      final pendingQuery = _firestore
          .collection(AppConstants.ordersCollection)
          .where(field, isEqualTo: userId)
          .where('status', isEqualTo: 'pending');
          
      final processingQuery = _firestore
          .collection(AppConstants.ordersCollection)
          .where(field, isEqualTo: userId)
          .where('status', whereIn: ['confirmed', 'processing', 'shipped']);
          
      final completedQuery = _firestore
          .collection(AppConstants.ordersCollection)
          .where(field, isEqualTo: userId)
          .where('status', whereIn: ['delivered', 'cancelled']);
      
      final pendingCount = (await pendingQuery.get()).size;
      final processingCount = (await processingQuery.get()).size;
      final completedCount = (await completedQuery.get()).size;
      
      return {
        'pending': pendingCount,
        'processing': processingCount,
        'completed': completedCount,
        'total': pendingCount + processingCount + completedCount,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting orders count: $e');
      }
      return {'pending': 0, 'processing': 0, 'completed': 0, 'total': 0};
    }
  }

  // Clear orders list
  void clearOrders() {
    _orders = [];
    _error = null;
    _lastDocumentId = null;
    _hasMore = true;
    notifyListeners();
  }
}
