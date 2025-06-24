import 'package:flutter/foundation.dart';
import 'package:woodline/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:woodline/constants/app_constants.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all products
  Future<void> fetchProducts({String? category}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Query query = _firestore.collection(AppConstants.productsCollection);
      
      // Filter by category if provided
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      
      // Order by creation date
      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();
      
      _products = querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
          
    } catch (e) {
      _error = 'Failed to fetch products';
      if (kDebugMode) {
        print('Error fetching products: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch products by owner
  Future<List<ProductModel>> fetchProductsByOwner(String ownerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user products: $e');
      }
      rethrow;
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting product: $e');
      }
      rethrow;
    }
  }

  // Add a new product
  Future<void> addProduct(ProductModel product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final docRef = _firestore.collection(AppConstants.productsCollection).doc();
      
      await docRef.set(product.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toMap());
      
      // Refresh the products list
      await fetchProducts();
      
    } catch (e) {
      _error = 'Failed to add product';
      if (kDebugMode) {
        print('Error adding product: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a product
  Future<void> updateProduct(ProductModel product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .update(product.copyWith(
            updatedAt: DateTime.now(),
          ).toMap()..remove('createdAt')); // Don't update createdAt
      
      // Refresh the products list
      await fetchProducts();
      
    } catch (e) {
      _error = 'Failed to update product';
      if (kDebugMode) {
        print('Error updating product: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .delete();
      
      // Remove from local list
      _products.removeWhere((product) => product.id == productId);
      
    } catch (e) {
      _error = 'Failed to delete product';
      if (kDebugMode) {
        print('Error deleting product: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear products list
  void clearProducts() {
    _products = [];
    _error = null;
    notifyListeners();
  }
}
