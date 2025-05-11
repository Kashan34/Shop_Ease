import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final DateTime orderDate;
  final String status;
  final String paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.status,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'orderDate': orderDate,
      'status': status,
      'paymentMethod': paymentMethod,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] as String,
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      total: map['total'] as double,
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      status: map['status'] as String,
      paymentMethod: map['paymentMethod'] as String,
    );
  }
}

class OrderItem {
  final Product product;
  final int quantity;
  final double price;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'productImage': product.imageUrl,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      product: Product(
        id: map['productId'] as String,
        name: map['productName'] as String,
        description: '', // Not needed for order history
        price: map['price'] as double,
        imageUrl: map['productImage'] as String,
        category: '', // Not needed for order history
        stock: 0, // Not needed for order history
        rating: 0, // Not needed for order history
        numReviews: 0, // Not needed for order history
      ),
      quantity: map['quantity'] as int,
      price: map['price'] as double,
    );
  }
}
