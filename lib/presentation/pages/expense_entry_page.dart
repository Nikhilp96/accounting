import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_entry_controller.dart';

class ExpenseEntryPage extends StatelessWidget {
  const ExpenseEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpenseEntryController());
    return Scaffold(
      appBar: AppBar(title: const Text('Add Daily Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Date Picker UI ---
            InkWell(
              onTap: () => controller.pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      'Date: ${controller.date.value.day}/${controller.date.value.month}/${controller.date.value.year}',
                      style: const TextStyle(fontSize: 16),
                    )),
                    const Icon(Icons.calendar_today, color: Colors.blueGrey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                items: controller.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => controller.selectedCategory.value = v!,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.saveExpense,
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
