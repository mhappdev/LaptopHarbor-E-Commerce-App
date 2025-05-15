import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/presentation/views/admin/screens/order/admin_orders_screen%20.dart';
import 'package:laptop_harbor/presentation/views/admin/screens/products/add_product_screen.dart';
import 'package:laptop_harbor/presentation/views/admin/screens/products/products_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> signOutUser(BuildContext context) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildAdminCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'View Products',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsScreen()),
              ),
            ),
            _buildAdminCard(
              context,
              icon: Icons.add_circle_outline,
              title: 'Add Product',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddProductScreen()),
              ),
            ),
            _buildAdminCard(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Manage Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminOrdersScreen()),
              ),
            ),
            _buildAdminCard(
              context,
              icon: Icons.analytics_outlined,
              title: 'Logout',
              onTap: () {
                signOutUser(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.blue.withOpacity(0.1),
                AppColors.blue.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
