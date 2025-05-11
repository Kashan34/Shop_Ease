import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  CartService({required this.userId});

  // Get cart items
  Stream<List<CartItem>> getCartItems() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .asyncMap((snapshot) async {
      List<CartItem> items = [];
      for (var doc in snapshot.docs) {
        final productId = doc.data()['productId'] as String;
        final quantity = doc.data()['quantity'] as int;
        final productDoc =
            await _firestore.collection('products').doc(productId).get();
        if (productDoc.exists) {
          final product =
              Product.fromMap({...productDoc.data()!, 'id': productDoc.id});
          items.add(CartItem(product: product, quantity: quantity));
        }
      }
      return items;
    });
  }

  // Add item to cart
  Future<void> addToCart(String productId) async {
    final cartRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    final doc = await cartRef.get();
    if (doc.exists) {
      await cartRef.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await cartRef.set({
        'productId': productId,
        'quantity': 1,
      });
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } else {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .update({'quantity': quantity});
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // Clear cart
  Future<void> clearCart() async {
    final batch = _firestore.batch();
    final cartItems = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
