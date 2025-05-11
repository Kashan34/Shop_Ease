import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize sample products
  Future<void> initializeSampleProducts() async {
    final products = [
      Product(
        id: '1',
        name: 'Smartphone',
        description: 'Latest model smartphone with advanced features',
        price: 999.99,
        imageUrl:
            'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500',
        category: 'Electronics',
        stock: 10,
        rating: 4.5,
        numReviews: 120,
      ),
      Product(
        id: '2',
        name: 'Laptop',
        description: 'High-performance laptop for work and gaming',
        price: 1499.99,
        imageUrl:
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500',
        category: 'Electronics',
        stock: 5,
        rating: 4.8,
        numReviews: 85,
      ),
      Product(
        id: '3',
        name: 'Headphones',
        description: 'Wireless noise-canceling headphones',
        price: 299.99,
        imageUrl:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500',
        category: 'Electronics',
        stock: 15,
        rating: 4.3,
        numReviews: 200,
      ),
    ];

    for (var product in products) {
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(product.toMap());
    }
  }

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Product.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Search products
  Stream<List<Product>> searchProducts(String query) {
    query = query.toLowerCase();
    return _firestore.collection('products').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Product.fromMap({...doc.data(), 'id': doc.id}))
            .where((product) =>
                product.name.toLowerCase().contains(query) ||
                product.description.toLowerCase().contains(query) ||
                product.category.toLowerCase().contains(query))
            .toList());
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (doc.exists) {
      return Product.fromMap({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  // Add new product
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  // Update product
  Future<void> updateProduct(String id, Product product) async {
    await _firestore.collection('products').doc(id).update(product.toMap());
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}
