import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate controller locally for this screen
    final controller = Get.put(SettingsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Item Rates'),
              Tab(text: 'Traders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // RATES TAB
            Obx(
              () => ListView.builder(
                itemCount: controller.rates.length,
                itemBuilder: (context, index) {
                  final rate = controller.rates[index];
                  return ListTile(
                    title: Text(rate.itemName),
                    trailing: Text(
                      '₹${rate.rate.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () => _showEditRateDialog(
                      context,
                      controller,
                      rate.itemName,
                      rate.rate,
                    ),
                  );
                },
              ),
            ),

            // TRADERS TAB
            Obx(
              () => ListView.builder(
                itemCount: controller.traders.length,
                itemBuilder: (context, index) {
                  final trader = controller.traders[index];
                  return ListTile(
                    title: Text(trader.name),
                    subtitle: Text(trader.category),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.file_download,
                    size: 80,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Restore Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This will overwrite your current app database with the data found in Downloads/accounting/shop_backup.xlsx.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  Obx(() {
                    if (controller.isRestoring.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade900,
                      ),
                      icon: const Icon(Icons.restore),
                      label: const Text(
                        'Restore from Excel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _confirmRestore(context, controller),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showAddTraderDialog(context, controller),
        ),
      ),
    );
  }

  void _confirmRestore(BuildContext context, SettingsController controller) {
    Get.defaultDialog(
      title: 'WARNING',
      titleStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          'This will delete all current local data and replace it with the Excel backup. Are you sure?',
      textConfirm: 'Yes, Restore',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // close dialog
        controller.triggerRestore();
      },
    );
  }

  void _showEditRateDialog(
    BuildContext context,
    SettingsController controller,
    String itemName,
    double currentRate,
  ) {
    final TextEditingController rateController = TextEditingController(
      text: currentRate.toString(),
    );
    Get.defaultDialog(
      title: 'Edit Rate: $itemName',
      content: TextField(
        controller: rateController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'New Rate (₹)'),
      ),
      textConfirm: 'Save',
      onConfirm: () {
        controller.updateRate(itemName, double.parse(rateController.text));
        Get.back();
      },
    );
  }

  void _showAddTraderDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final TextEditingController nameController = TextEditingController();
    String selectedCategory = 'Broiler';

    Get.defaultDialog(
      title: 'Add New Trader',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Trader Name'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items: [
              'Broiler',
              'Desi',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => selectedCategory = val!,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
        ],
      ),
      textConfirm: 'Add',
      onConfirm: () {
        controller.addTrader(nameController.text, selectedCategory);
        Get.back();
      },
    );
  }
}
