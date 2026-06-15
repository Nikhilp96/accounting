import 'package:accounting/core/utils/backup_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class TransferEntryController extends GetxController {
  final TransferRepository _transferRepo = Get.find<TransferRepository>();

  // Editing support
  TransferModel? editingTransfer;
  bool get isEditing => editingTransfer != null;

  var date = DateTime.now().obs;
  var fromShop = 'NK'.obs;
  var toShop = 'NP'.obs;
  var itemType = 'Broiler'.obs;

  var qty = 0.0.obs;
  var weight1 = 0.0.obs;
  var weight2 = 0.0.obs;

  final qtyController = TextEditingController();
  final weight1Controller = TextEditingController();
  final weight2Controller = TextEditingController();

  final shops = ['NK', 'NP', 'PT'];
  final itemTypes = ['Broiler', 'DP', 'OG'];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args.containsKey('transfer')) {
      _loadExisting(args['transfer'] as TransferModel);
    }
  }

  void _loadExisting(TransferModel transfer) {
    editingTransfer = transfer;
    date.value = DateTime.parse(transfer.date);
    fromShop.value = transfer.fromShop;
    toShop.value = transfer.toShop;
    itemType.value = transfer.itemType;
    qty.value = transfer.qty;
    weight1.value = transfer.weight1;
    weight2.value = transfer.weight2;

    qtyController.text = transfer.qty > 0 ? transfer.qty.toString() : '';
    weight1Controller.text =
        transfer.weight1 > 0 ? transfer.weight1.toString() : '';
    weight2Controller.text =
        transfer.weight2 > 0 ? transfer.weight2.toString() : '';
  }

  @override
  void onClose() {
    qtyController.dispose();
    weight1Controller.dispose();
    weight2Controller.dispose();
    super.onClose();
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

  void updateFromShop(String val) {
    fromShop.value = val;
    if (fromShop.value == toShop.value) {
      toShop.value = shops.firstWhere((s) => s != fromShop.value);
    }
  }

  void updateToShop(String val) {
    toShop.value = val;
    if (toShop.value == fromShop.value) {
      fromShop.value = shops.firstWhere((s) => s != toShop.value);
    }
  }

  void swapShops() {
    final temp = fromShop.value;
    fromShop.value = toShop.value;
    toShop.value = temp;
  }

  void onWeight1Changed(String val) {
    weight1.value = double.tryParse(val) ?? 0.0;
    if (itemType.value == 'Broiler' && weight1.value > 0) {
      weight2.value = 0.0;
      weight2Controller.clear();
    }
  }

  void onWeight2Changed(String val) {
    weight2.value = double.tryParse(val) ?? 0.0;
    if (itemType.value == 'Broiler' && weight2.value > 0) {
      weight1.value = 0.0;
      weight1Controller.clear();
    }
  }

  void saveTransfer() async {
    if (fromShop.value == toShop.value) {
      Get.snackbar(
        'Error',
        'Source and Destination shop cannot be the same.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
      return;
    }
    if (itemType.value == 'Broiler' &&
        weight1.value > 0 &&
        weight2.value > 0) {
      Get.snackbar(
        'Error',
        'Broiler cannot have both Small and Big weights simultaneously.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
      return;
    }
    if (weight1.value <= 0 && weight2.value <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid transfer weight.',
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    final transfer = TransferModel(
      id: editingTransfer?.id,
      date: date.value.toIso8601String(),
      fromShop: fromShop.value,
      toShop: toShop.value,
      itemType: itemType.value,
      qty: qty.value,
      weight1: weight1.value,
      weight2: weight2.value,
    );

    if (isEditing) {
      await _transferRepo.updateTransfer(transfer);
    } else {
      await _transferRepo.addTransfer(transfer);
    }
    await BackupManager.instance.flushNow();

    Get.back();
    Get.snackbar(
      'Success',
      isEditing
          ? 'Transfer updated successfully.'
          : 'Stock transfer logged successfully.',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }
}
