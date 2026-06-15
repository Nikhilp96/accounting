import 'package:accounting/core/utils/backup_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

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

  final ExpenseRepository _expenseRepo = Get.find<ExpenseRepository>();
  final ExpenseCategoryRepository _catRepo =
      Get.find<ExpenseCategoryRepository>();

  bool get isEditMode => editData != null;
  var isReady = false.obs; // Tracks if DB categories are loaded
  var date = DateTime.now().obs;

  var categoryNames = <String>[].obs;
  var expenseRows = <ExpenseRowData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await loadCategories();

    if (isEditMode) {
      date.value = DateTime.parse(editData!.date);
      // Auto-add category if it somehow doesn't exist in DB
      if (!categoryNames.contains(editData!.category)) {
        await addCustomCategory(editData!.category, false);
      }
      expenseRows.add(
        ExpenseRowData(
          initialCategory: editData!.category,
          initialAmount: editData!.amount.toString(),
        ),
      );
    } else {
      addRow();
    }
    isReady.value = true;
  }

  Future<void> loadCategories() async {
    final cats = await _catRepo.getAllCategories();
    categoryNames.value = cats.map((e) => e.name).toList();
  }

  Future<void> addCustomCategory(String name, bool isSalary) async {
    if (name.isEmpty) return;
    if (categoryNames.contains(name)) {
      Get.snackbar(
        'Notice',
        'Category already exists',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    final newCat = ExpenseCategoryModel(name: name, isSalary: isSalary);
    await _catRepo.addCategory(newCat);
    await loadCategories();
    Get.snackbar(
      'Success',
      'Category Saved',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  void addRow() {
    String initCat = categoryNames.isNotEmpty ? categoryNames.first : '';
    expenseRows.add(ExpenseRowData(initialCategory: initCat));
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
    if (picked != null) date.value = picked;
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
            notes: isEditMode ? editData?.notes ?? "" : '',
          ),
        );
      }
    }

    if (validExpensesToSave.isEmpty) return;

    try {
      if (isEditMode) {
        await _expenseRepo.updateExpense(validExpensesToSave.first);
      } else {
        for (var exp in validExpensesToSave) {
          await _expenseRepo.addExpense(exp);
        }
      }
      BackupManager.instance.scheduleBackup();
      Get.back();
      Get.snackbar(
        'Success',
        'Expenses saved successfully',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Save Failed',
        'Could not save expense: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
