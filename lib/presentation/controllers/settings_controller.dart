import 'package:accounting/core/utils/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class SettingsController extends GetxController {
  final RateRepository _rateRepo = RateRepository();
  final TraderRepository _traderRepo = TraderRepository();

  var rates = <RateModel>[].obs;
  var traders = <TraderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    rates.value = await _rateRepo.getAllRates();
    traders.value = await _traderRepo.getAllTraders();
  }

  Future<void> updateRate(String itemName, double newRate) async {
    await _rateRepo.updateRate(itemName, newRate);
    await BackupService.exportToExcel();
    loadData();
  }

  Future<void> addTrader(String name, String category) async {
    await _traderRepo.addTrader(TraderModel(name: name, category: category));
    await BackupService.exportToExcel();
    loadData();
  }

  var isRestoring = false.obs;

  Future<void> triggerRestore() async {
    isRestoring.value = true;

    bool success = await BackupService.restoreFromExcel();

    if (success) {
      // Reload UI data to reflect the restored database
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
