import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Header
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user?.email?[0].toUpperCase() ?? '?',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'No email',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),

                // Orders Section
                _buildSection(
                  context,
                  'Orders',
                  Icons.shopping_bag,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderHistoryScreen()),
                  ),
                ),

                // Payment Methods Section
                _buildSection(
                  context,
                  'Payment Methods',
                  Icons.payment,
                  () => _showPaymentMethods(context),
                ),

                // Help & Support Section
                _buildSection(
                  context,
                  'Help & Support',
                  Icons.help,
                  () => _showHelpSupport(context),
                ),

                // About Section
                _buildSection(
                  context,
                  'About',
                  Icons.info,
                  () => _showAbout(context),
                ),
              ],
            ),
          ),
          // Logout Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await context.read<AuthService>().signOut();
                          if (context.mounted) {
                            Navigator.pop(context); // Close dialog
                          }
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showPaymentMethods(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Methods'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentMethod('EasyPaisa', Icons.phone_android),
              _buildPaymentMethod('JazzCash', Icons.phone_android),
              _buildPaymentMethod('SadaPay', Icons.phone_android),
              _buildPaymentMethod('Credit Card', Icons.credit_card),
              _buildPaymentMethod('Debit Card', Icons.credit_card),
              _buildPaymentMethod('Bank Transfer', Icons.account_balance),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Text(name),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactInfo(
                'Customer Service',
                '+92 300 1234567',
                'support@shoppingapp.pk',
              ),
              const SizedBox(height: 16),
              _buildContactInfo(
                'Technical Support',
                '+92 321 7654321',
                'tech@shoppingapp.pk',
              ),
              const SizedBox(height: 16),
              _buildContactInfo(
                'Sales Department',
                '+92 333 9876543',
                'sales@shoppingapp.pk',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String title, String phone, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Phone: $phone'),
        Text('Email: $email'),
      ],
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Us'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Pakistan\'s Premier Shopping Destination',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Founded in 2024, we are committed to revolutionizing the shopping experience in Pakistan. Our platform brings together the best local and international brands, offering a seamless shopping experience to our customers.',
              ),
              SizedBox(height: 16),
              Text(
                'Our Mission:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'To provide quality products at competitive prices while ensuring excellent customer service and a user-friendly shopping experience.',
              ),
              SizedBox(height: 16),
              Text(
                'Our Vision:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'To become Pakistan\'s leading e-commerce platform, setting new standards in customer satisfaction and service excellence.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
