import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/backup_service.dart';

class DashboardController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _requestInitialPermissions();
  }

  Future<void> _requestInitialPermissions() async {
    // This triggers the Android system dialog using your existing service
    bool granted = await BackupService.requestPermissions();

    if (!granted) {
      Get.snackbar(
        'Permission Required',
        'Storage permission is needed to automatically backup your accounting data to the Downloads folder.',
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
    }
  }
}
