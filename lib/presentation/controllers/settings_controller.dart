import 'package:accounting/core/utils/backup_manager.dart';
import 'package:accounting/core/utils/backup_service.dart';
import 'package:accounting/core/cache/app_cache.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class SettingsController extends GetxController {
  final RateRepository _rateRepo = Get.find<RateRepository>();
  final TraderRepository _traderRepo = Get.find<TraderRepository>();
  final ExpenseCategoryRepository _catRepo =
      Get.find<ExpenseCategoryRepository>();

  var rates = <RateModel>[].obs;
  var traders = <TraderModel>[].obs;
  var expenseCategories = <ExpenseCategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    rates.value = await _rateRepo.getAllRates();
    traders.value = await _traderRepo.getAllTraders();
    expenseCategories.value = await _catRepo.getAllCategories();
  }

  Future<void> updateRate(String itemName, double newRate) async {
    try {
      await _rateRepo.updateRate(itemName, newRate);
      AppCache.instance.invalidateRates();
      BackupManager.instance.scheduleBackup();
      loadData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update rate: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addTrader(String name, String category) async {
    try {
      await _traderRepo.addTrader(TraderModel(name: name, category: category));
      AppCache.instance.invalidateTraders();
      BackupManager.instance.scheduleBackup();
      loadData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add trader: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // --- Expense Category Management ---
  Future<void> addExpenseCategory(String name, {bool isSalary = false}) async {
    try {
      await _catRepo.addCategory(
        ExpenseCategoryModel(name: name, isSalary: isSalary),
      );
      BackupManager.instance.scheduleBackup();
      loadData();
      Get.snackbar(
        'Added',
        'Category "$name" added successfully.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add category: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateExpenseCategory(ExpenseCategoryModel category) async {
    try {
      await _catRepo.updateCategory(category);
      BackupManager.instance.scheduleBackup();
      loadData();
      Get.snackbar(
        'Updated',
        'Category updated successfully.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update category: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteExpenseCategory(int id) async {
    try {
      await _catRepo.deleteCategory(id);
      BackupManager.instance.scheduleBackup();
      loadData();
      Get.snackbar(
        'Deleted',
        'Category removed.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  var isRestoring = false.obs;

  Future<void> triggerRestore() async {
    isRestoring.value = true;

    bool success = await BackupService.restoreFromExcel();

    if (success) {
      AppCache.instance.invalidateAll();
      await loadData();
      Get.snackbar(
        'Restore Successful',
        'Database has been rebuilt from the Excel file.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Restore Failed',
        'Could not find backup.xlsx or permission denied.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
    }

    isRestoring.value = false;
  }
}
