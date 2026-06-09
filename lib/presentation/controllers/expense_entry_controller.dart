import 'package:accounting/core/utils/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

// Helper class without the notes controller
class ExpenseRowData {
  final RxString selectedCategory;
  final TextEditingController amountController;

  ExpenseRowData({required String initialCategory, String initialAmount = ''})
    : selectedCategory = initialCategory.obs,
      amountController = TextEditingController(text: initialAmount);

  void dispose() {
    amountController.dispose();
  }
}

class ExpenseEntryController extends GetxController {
  late final String shopCode;
  ExpenseModel? editData;

  ExpenseEntryController() {
    final args = Get.arguments;
    if (args is Map) {
      shopCode = args['shopCode'];
      editData = args['expense'];
    } else {
      shopCode = args ?? 'Unknown';
    }
  }

  final ExpenseRepository _expenseRepo = ExpenseRepository();
  bool get isEditMode => editData != null;

  var date = DateTime.now().obs;

  final List<String> categories = [
    'चहा',
    'नाश्ता',
    'दाणा',
    'पिशवी',
    'पाणी',
    'Light Bill',
    'Waste Tax',
    'Rent',
    'Labor',
    'Labor food',
    'Self',
    'Other',
  ];

  var expenseRows = <ExpenseRowData>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (isEditMode) {
      date.value = DateTime.parse(editData!.date);
      expenseRows.add(
        ExpenseRowData(
          initialCategory: editData!.category,
          initialAmount: editData!.amount.toString(),
        ),
      );
    } else {
      addRow();
    }
  }

  @override
  void onClose() {
    for (var row in expenseRows) {
      row.dispose();
    }
    super.onClose();
  }

  void addRow() {
    expenseRows.add(ExpenseRowData(initialCategory: 'Other'));
  }

  void removeRow(int index) {
    if (expenseRows.length > 1) {
      expenseRows[index].dispose();
      expenseRows.removeAt(index);
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
    List<ExpenseModel> validExpensesToSave = [];

    for (var row in expenseRows) {
      double amount = double.tryParse(row.amountController.text) ?? 0.0;
      if (amount > 0) {
        validExpensesToSave.add(
          ExpenseModel(
            id: isEditMode ? editData!.id : null,
            shopCode: shopCode,
            date: date.value.toIso8601String(),
            category: row.selectedCategory.value,
            amount: amount,
            notes: '', // Passed as empty string to satisfy the database model
          ),
        );
      }
    }

    if (validExpensesToSave.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter at least one valid expense amount.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    try {
      if (isEditMode) {
        await _expenseRepo.updateExpense(validExpensesToSave.first);
      } else {
        for (var exp in validExpensesToSave) {
          await _expenseRepo.addExpense(exp);
        }
      }

      await BackupService.exportToExcel();
      Get.back();
      Get.snackbar(
        'Success',
        'Expenses saved successfully',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save expense',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
    }
  }
}
