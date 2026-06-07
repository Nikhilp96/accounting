import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class ExpenseEntryController extends GetxController {
  final String shopCode = Get.arguments;
  final ExpenseRepository _expenseRepo = ExpenseRepository();

  var date = DateTime.now().obs;
  var selectedCategory = 'चहा'.obs;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final List<String> categories = [
    'चहा',
    'नाश्ता',
    'दाणा',
    'पिशवी',
    'पाणी',
    'Light Bill',
    'Waste Tax',
    'Rent',
    'Other',
  ];

  Future<void> saveExpense() async {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar('Error', 'Enter valid amount', backgroundColor: Colors.red);
      return;
    }

    await _expenseRepo.addExpense(
      ExpenseModel(
        shopCode: shopCode,
        date: date.value.toIso8601String(),
        category: selectedCategory.value,
        amount: amount,
        notes: notesController.text,
      ),
    );
    Get.back();
    Get.snackbar('Success', 'Expense saved');
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      date.value = picked;
    }
  }
}
