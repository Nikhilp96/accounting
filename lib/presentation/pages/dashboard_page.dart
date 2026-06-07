import 'package:accounting/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart'; // Add this import

// Change StatelessWidget to GetView<DashboardController>
class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('My Shops Accounting'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Master Settings',
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShopTile('Shop NK', 'NK', Colors.blueGrey),
              const SizedBox(height: 20),
              _buildShopTile('Shop NP', 'NP', Colors.teal),
              const SizedBox(height: 20),
              _buildShopTile('Shop PT', 'PT', Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopTile(String title, String shopCode, Color color) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.SHOP_HOME, arguments: shopCode);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, color: color, size: 32),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
