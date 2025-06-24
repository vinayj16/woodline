import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String sellerId;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String status; // pending, confirmed, processing, shipped, delivered, cancelled
  final String? trackingNumber;
  final String? shippingAddress;
  final String? customerNotes;
  final String? sellerNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPaid;
  final String? paymentMethod;
  final String? paymentId;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.sellerId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    this.status = 'pending',
    this.trackingNumber,
    this.shippingAddress,
    this.customerNotes,
    this.sellerNotes,
    required this.createdAt,
    required this.updatedAt,
    this.isPaid = false,
    this.paymentMethod,
    this.paymentId,
  });

  // Create OrderModel from Firestore document
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shippingFee: (data['shippingFee'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      trackingNumber: data['trackingNumber'],
      shippingAddress: data['shippingAddress'],
      customerNotes: data['customerNotes'],
      sellerNotes: data['sellerNotes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
      paymentMethod: data['paymentMethod'],
      paymentId: data['paymentId'],
    );
  }

  // Convert OrderModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'sellerId': sellerId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'status': status,
      'trackingNumber': trackingNumber,
      'shippingAddress': shippingAddress,
      'customerNotes': customerNotes,
      'sellerNotes': sellerNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPaid': isPaid,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
    };
  }

  // Create a copy of the order with some fields updated
  OrderModel copyWith({
    String? id,
    String? customerId,
    String? sellerId,
    List<OrderItem>? items,
    double? subtotal,
    double? shippingFee,
    double? totalAmount,
    String? status,
    String? trackingNumber,
    String? shippingAddress,
    String? customerNotes,
    String? sellerNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPaid,
    String? paymentMethod,
    String? paymentId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      sellerId: sellerId ?? this.sellerId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      customerNotes: customerNotes ?? this.customerNotes,
      sellerNotes: sellerNotes ?? this.sellerNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPaid: isPaid ?? this.isPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final Map<String, dynamic>? customizations;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.customizations,
  });

  // Create OrderItem from Map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'],
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      customizations: map['customizations'] != null
          ? Map<String, dynamic>.from(map['customizations'])
          : null,
    );
  }

  // Convert OrderItem to Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      if (customizations != null) 'customizations': customizations,
    };
  }

  // Calculate item total
  double get total => price * quantity;

  // Create a copy of the order item with some fields updated
  OrderItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    Map<String, dynamic>? customizations,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
    );
  }
}
