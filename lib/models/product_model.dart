import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String? woodType;
  final String? dimensions;
  final int estimatedDays;
  final String ownerId;
  final bool isCustomOrderAvailable;
  final bool isAvailable;
  final double? rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.category,
    this.woodType,
    this.dimensions,
    required this.estimatedDays,
    required this.ownerId,
    this.isCustomOrderAvailable = false,
    this.isAvailable = true,
    this.rating,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a ProductModel from a Firestore document
  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ProductModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      category: data['category'] ?? 'other',
      woodType: data['woodType'],
      dimensions: data['dimensions'],
      estimatedDays: data['estimatedDays'] ?? 7,
      ownerId: data['ownerId'],
      isCustomOrderAvailable: data['isCustomOrderAvailable'] ?? false,
      isAvailable: data['isAvailable'] ?? true,
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert ProductModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'category': category,
      'woodType': woodType,
      'dimensions': dimensions,
      'estimatedDays': estimatedDays,
      'ownerId': ownerId,
      'isCustomOrderAvailable': isCustomOrderAvailable,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy of the product with some fields updated
  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    List<String>? imageUrls,
    String? category,
    String? woodType,
    String? dimensions,
    int? estimatedDays,
    String? ownerId,
    bool? isCustomOrderAvailable,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      woodType: woodType ?? this.woodType,
      dimensions: dimensions ?? this.dimensions,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      ownerId: ownerId ?? this.ownerId,
      isCustomOrderAvailable: isCustomOrderAvailable ?? this.isCustomOrderAvailable,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
