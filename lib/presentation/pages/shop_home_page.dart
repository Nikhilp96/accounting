import 'package:accounting/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopHomePage extends StatelessWidget {
  const ShopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String shopCode = Get.arguments ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Matching soft background
      appBar: AppBar(
        title: Text(
          'Shop $shopCode',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blueGrey.shade100,
                    child: Icon(
                      Icons.store,
                      size: 32,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shop Dashboard',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Code: $shopCode',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // --- Action Cards ---
              _buildActionCard(
                title: 'Enter Purchases',
                subtitle: 'Record stock, birds, and material intake',
                icon: Icons.add_shopping_cart,
                color: Colors.teal,
                onTap: () =>
                    Get.toNamed(Routes.PURCHASE_ENTRY, arguments: shopCode),
              ),
              const SizedBox(height: 16),

              _buildActionCard(
                title: 'Enter Weekly Sales',
                subtitle: 'Log sales amounts, weights, and differences',
                icon: Icons.point_of_sale,
                color: Colors.indigo,
                onTap: () =>
                    Get.toNamed(Routes.SALES_ENTRY, arguments: shopCode),
              ),
              const SizedBox(height: 16),

              _buildActionCard(
                title: 'Enter Expenses',
                subtitle: 'Log expense details and amounts',
                icon: Icons.money,
                color: Colors.orange,
                onTap: () =>
                    Get.toNamed(Routes.EXPENSE_ENTRY, arguments: shopCode),
              ),
              const SizedBox(height: 16),

              _buildActionCard(
                title: 'View Reports & Ledgers',
                subtitle: 'Analyze profit, balances, and expenses',
                icon: Icons.analytics_outlined,
                color: Colors.brown,
                onTap: () => Get.toNamed(Routes.REPORTS, arguments: shopCode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for beautifully styled action cards
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade300,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
