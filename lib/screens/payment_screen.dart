import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../models/order.dart';

class PaymentScreen extends StatefulWidget {
  final double total;

  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPaymentMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'EasyPaisa',
      'icon': Icons.phone_android,
      'color': Colors.blue,
    },
    {
      'name': 'SadaPay',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {
      'name': 'JazzCash',
      'icon': Icons.payment,
      'color': Colors.orange,
    },
    {
      'name': 'Credit Card',
      'icon': Icons.credit_card,
      'color': Colors.purple,
    },
  ];

  Future<void> _processPayment() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Get cart items
      final cartItems = await context.read<CartService>().getCartItems().first;

      // Create order items
      final orderItems = cartItems
          .map((item) => OrderItem(
                product: item.product,
                quantity: item.quantity,
                price: item.product.price,
              ))
          .toList();

      // Create order
      final order = Order(
        id: '', // Firestore will generate this
        userId: userId,
        items: orderItems,
        total: widget.total,
        orderDate: DateTime.now(),
        status: 'Confirmed',
        paymentMethod: selectedPaymentMethod!,
      );

      // Save order to Firestore
      await firestore.FirebaseFirestore.instance
          .collection('orders')
          .add(order.toMap());

      // Clear cart
      await context.read<CartService>().clearCart();

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Successful!'),
            content: Text(
              'Your order of \$${widget.total.toStringAsFixed(2)} has been confirmed.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to home
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  final isSelected = selectedPaymentMethod == method['name'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected ? method['color'].withOpacity(0.1) : null,
                    child: ListTile(
                      leading: Icon(
                        method['icon'],
                        color: method['color'],
                        size: 32,
                      ),
                      title: Text(
                        method['name'],
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : null,
                          color: isSelected ? method['color'] : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: method['color'])
                          : null,
                      onTap: () {
                        setState(() {
                          selectedPaymentMethod = method['name'];
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirm Payment'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
