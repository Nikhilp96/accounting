import 'package:accounting/presentation/pages/expense_entry_page.dart';
import 'package:accounting/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopHomePage extends StatelessWidget {
  const ShopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the shop code passed from the Dashboard
    final String shopCode = Get.arguments ?? 'Unknown';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Shop $shopCode Dashboard'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.teal.shade100,
                ),
                icon: const Icon(Icons.add_shopping_cart, size: 30),
                label: const Text(
                  'Enter Purchases',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Get.toNamed(Routes.PURCHASE_ENTRY, arguments: shopCode);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.indigo.shade100,
                ),
                icon: const Icon(Icons.point_of_sale, size: 30),
                label: const Text(
                  'Enter Weekly Sales',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Get.toNamed(Routes.SALES_ENTRY, arguments: shopCode);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.orange.shade100,
                ),
                icon: const Icon(Icons.money_off, size: 30),
                label: const Text(
                  'Add Expense',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () =>
                    Get.toNamed(Routes.EXPENSE_ENTRY, arguments: shopCode),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.grey.shade300,
                ),
                icon: const Icon(Icons.receipt_long, size: 30),
                label: const Text(
                  'View Reports',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Get.toNamed(Routes.REPORTS, arguments: shopCode);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
