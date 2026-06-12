import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_entry_controller.dart';

class ExpenseEntryPage extends StatelessWidget {
  const ExpenseEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpenseEntryController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          controller.isEditMode ? 'Edit Expense' : 'Add Daily Expenses',
        ),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (!controller.isReady.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          return Column(
            children: [
              // --- Sticky Date Header ---
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: ${DateUtil.format(controller.date.value)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        Icon(
                          Icons.calendar_month,
                          color: Colors.orange.shade800,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Scrollable Dynamic Rows ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.expenseRows.length,
                  itemBuilder: (context, index) {
                    return _buildExpenseRow(
                      context,
                      controller,
                      controller.expenseRows[index],
                      index,
                    );
                  },
                ),
              ),

              // --- Footer Buttons ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (!controller.isEditMode)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 50),
                          side: BorderSide(color: Colors.orange.shade800),
                          foregroundColor: Colors.orange.shade800,
                        ),
                        onPressed: controller.addRow,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text(
                          'Add Another Expense',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: controller.saveExpense,
                      child: Text(
                        controller.isEditMode
                            ? 'Update Expense'
                            : 'Save All Expenses',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildExpenseRow(
    BuildContext context,
    ExpenseEntryController controller,
    ExpenseRowData row,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense #${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              if (!controller.isEditMode && controller.expenseRows.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () => controller.removeRow(index),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // --- DYNAMIC DROPDOWN WITH ADD BUTTON ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                // --- FIX: Wrapped in Obx to refresh when new category is added ---
                child: Obx(() {
                  // Ensure value exists in list to prevent Flutter Exception
                  String? currentVal = row.selectedCategory.value;
                  if (currentVal.isEmpty ||
                      !controller.categoryNames.contains(currentVal)) {
                    currentVal = null;
                  }

                  return DropdownButtonFormField<String>(
                    value: currentVal,
                    items: controller.categoryNames
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => row.selectedCategory.value = v!,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  tooltip: 'Create New Category',
                  icon: Icon(Icons.add_circle, color: Colors.orange.shade800),
                  onPressed: () =>
                      _showAddCategoryDialog(context, controller, row),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: row.amountController,
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  // --- DIALOG FOR CREATING CUSTOM CATEGORIES ---
  void _showAddCategoryDialog(
    BuildContext context,
    ExpenseEntryController controller,
    ExpenseRowData row,
  ) {
    final nameCtrl = TextEditingController();
    bool isSalary = false;

    Get.dialog(
      AlertDialog(
        title: const Text('Create New Category'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Raju Salary or Delivery',
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text(
                    'Is this an Employee Salary?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Checking this tags it for Payroll Analytics.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: isSalary,
                  onChanged: (val) => setState(() => isSalary = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.orange.shade800,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              String newCatName = nameCtrl.text.trim();
              if (newCatName.isNotEmpty) {
                // --- FIX: Close dialog BEFORE calling the async controller method ---
                Get.back();

                await controller.addCustomCategory(newCatName, isSalary);

                // Auto-select the newly created category in the dropdown
                row.selectedCategory.value = newCatName;
              }
            },
            child: const Text('Save Category'),
          ),
        ],
      ),
    );
  }
}
