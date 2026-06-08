import 'package:accounting/core/utils/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class ExpenseEntryController extends GetxController {
  late final String shopCode;
  ExpenseModel? editData;

  ExpenseEntryController() {
    // Smart argument parsing for both Add and Edit modes
    final args = Get.arguments;
    if (args is Map) {
      shopCode = args['shopCode'];
      editData = args['expense'];
    } else {
      shopCode = args ?? 'Unknown';
    }
  }

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

  @override
  void onInit() {
    super.onInit();
    // Pre-fill data if in Edit Mode
    if (editData != null) {
      date.value = DateTime.parse(editData!.date);
      selectedCategory.value = editData!.category;
      amountController.text = editData!.amount.toString();
      notesController.text = editData!.notes;
    }
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

  Future<void> saveExpense() async {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'Enter valid amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final expense = ExpenseModel(
      id: editData?.id, // Null for new, populated for edit
      shopCode: shopCode,
      date: date.value.toIso8601String(),
      category: selectedCategory.value,
      amount: amount,
      notes: notesController.text,
    );

    try {
      if (editData != null) {
        await _expenseRepo.updateExpense(expense);
      } else {
        await _expenseRepo.addExpense(expense);
      }

      await BackupService.exportToExcel(); // Trigger backup after DB success
      Get.back();
      Get.snackbar(
        'Success',
        'Expense saved successfully',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save expense',
        backgroundColor: Colors.red,
      );
    }
  }
}
