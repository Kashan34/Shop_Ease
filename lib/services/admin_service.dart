import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  AdminService({required this.userId});

  // Check if user is admin
  Future<bool> isAdmin() async {
    final adminDoc = await _firestore.collection('admins').doc(userId).get();
    return adminDoc.exists && adminDoc.data()?['isAdmin'] == true;
  }

  // Get all products
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Add new product
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'category': product.category,
      'stock': product.stock,
      'rating': product.rating,
      'numReviews': product.numReviews,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'category': product.category,
      'stock': product.stock,
      'rating': product.rating,
      'numReviews': product.numReviews,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Get product by ID
  Future<Product?> getProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromMap({...doc.data()!, 'id': doc.id});
  }

  // Get all users
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  // Get all orders
  Stream<QuerySnapshot> getAllOrders() {
    return _firestore.collection('orders').snapshots();
  }
}
