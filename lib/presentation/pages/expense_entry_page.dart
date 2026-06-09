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
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Sticky Date Header ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => controller.pickDate(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          'Date: ${DateUtil.format(controller.date.value)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_month, color: Colors.orange.shade800),
                    ],
                  ),
                ),
              ),
            ),

            // --- Scrollable Dynamic Rows ---
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.expenseRows.length,
                  itemBuilder: (context, index) {
                    final row = controller.expenseRows[index];
                    return _buildExpenseRow(controller, row, index);
                  },
                ),
              ),
            ),

            // --- Footer Buttons ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Only allow adding rows if we are NOT in edit mode
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
        ),
      ),
    );
  }

  Widget _buildExpenseRow(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => controller.removeRow(index),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Obx(
            () => DropdownButtonFormField<String>(
              value: row.selectedCategory.value,
              items: controller.categories
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
            ),
          ),
          const SizedBox(height: 16),

          // Amount field now takes full width since Notes is gone
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
}
