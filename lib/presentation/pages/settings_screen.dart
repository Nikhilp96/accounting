import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Master Settings'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Item Rates'),
              Tab(text: 'Traders'),
              Tab(text: 'Expense Categories'),
              Tab(text: 'Backup'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
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
              _buildTradersTab(controller),

              // EXPENSE CATEGORIES TAB
              _buildExpenseCategoriesTab(controller),

              // BACKUP TAB
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
        ),
      ),
    );
  }

  // --- Traders Tab ---
  Widget _buildTradersTab(SettingsController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Manage Traders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Trader'),
                onPressed: () =>
                    _showAddTraderDialog(Get.context!, controller),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Obx(() {
            if (controller.traders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No traders yet.\nTap "Add Trader" to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: controller.traders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final trader = controller.traders[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Icon(
                      Icons.person,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  title: Text(
                    trader.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(trader.category),
                );
              },
            );
          }),
        ),
      ],
    );
  }
  Widget _buildExpenseCategoriesTab(SettingsController controller) {
    return Column(
      children: [
        // Add button header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Manage Expense Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Category'),
                onPressed: () => _showAddCategoryDialog(controller),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Categories list
        Expanded(
          child: Obx(() {
            if (controller.expenseCategories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expense categories yet.\nTap "Add Category" to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: controller.expenseCategories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = controller.expenseCategories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade50,
                    child: Icon(
                      Icons.label_outlined,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: category.isSalary
                      ? Text(
                          'Salary type',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Colors.blue.shade700,
                        ),
                        onPressed: () =>
                            _showEditCategoryDialog(controller, category),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade700,
                        ),
                        onPressed: () =>
                            _confirmDeleteCategory(controller, category),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showAddCategoryDialog(SettingsController controller) {
    final nameController = TextEditingController();
    var isSalary = false.obs;

    Get.defaultDialog(
      title: 'Add Expense Category',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      radius: 12,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
              hintText: 'e.g. चहा, Light Bill, Rent',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          Obx(
            () => CheckboxListTile(
              title: const Text('Is Salary Type?'),
              value: isSalary.value,
              onChanged: (val) => isSalary.value = val ?? false,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      textConfirm: 'Add',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange.shade700,
      onConfirm: () {
        final name = nameController.text.trim();
        if (name.isEmpty) {
          Get.snackbar(
            'Error',
            'Please enter a category name.',
            backgroundColor: Colors.orange.shade800,
            colorText: Colors.white,
          );
          return;
        }
        Get.back();
        controller.addExpenseCategory(name, isSalary: isSalary.value);
      },
    );
  }

  void _showEditCategoryDialog(
    SettingsController controller,
    ExpenseCategoryModel category,
  ) {
    final nameController = TextEditingController(text: category.name);
    var isSalary = category.isSalary.obs;

    Get.defaultDialog(
      title: 'Edit Category',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      radius: 12,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          Obx(
            () => CheckboxListTile(
              title: const Text('Is Salary Type?'),
              value: isSalary.value,
              onChanged: (val) => isSalary.value = val ?? false,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue.shade700,
      onConfirm: () {
        final name = nameController.text.trim();
        if (name.isEmpty) {
          Get.snackbar(
            'Error',
            'Please enter a category name.',
            backgroundColor: Colors.orange.shade800,
            colorText: Colors.white,
          );
          return;
        }
        Get.back();
        controller.updateExpenseCategory(
          ExpenseCategoryModel(
            id: category.id,
            name: name,
            isSalary: isSalary.value,
          ),
        );
      },
    );
  }

  void _confirmDeleteCategory(
    SettingsController controller,
    ExpenseCategoryModel category,
  ) {
    Get.defaultDialog(
      title: 'Delete Category',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText:
          'Are you sure you want to delete "${category.name}"? This will not affect existing expense records.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      cancelTextColor: Colors.grey.shade800,
      radius: 12,
      onConfirm: () {
        Get.back();
        controller.deleteExpenseCategory(category.id!);
      },
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
        Get.back();
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
            initialValue: selectedCategory,
            items: [
              'Broiler',
              'Desi',
              'Eggs',
              'Pota Kalegi',
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
