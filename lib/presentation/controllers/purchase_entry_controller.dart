import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class PurchaseEntryController extends GetxController {
  late final String shopCode;
  PurchaseModel? editData;

  PurchaseEntryController() {
    // Smart argument parsing
    final args = Get.arguments;
    if (args is Map) {
      shopCode = args['shopCode'];
      editData = args['purchase'];
    } else {
      shopCode = args ?? 'Unknown';
    }
  }

  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  final TraderRepository _traderRepo = TraderRepository();

  // Selected Category
  var selectedItemType = 'Broiler'.obs;

  // Form Inputs
  var date = DateTime.now().obs;
  var quantity = 0.obs;
  var weight1 = 0.0.obs; // Small Chicken OR DP Weight
  var weight2 = 0.0.obs; // Big Chicken OR OG Weight
  var rate = 0.0.obs;
  var selectedTraderId = Rxn<int>();

  // Text Controllers
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController weight1Controller = TextEditingController();
  final TextEditingController weight2Controller = TextEditingController();

  var availableTraders = <TraderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTradersForType();
    ever(selectedItemType, (_) => _loadTradersForType());

    // --- PRE-FILL DATA FOR EDIT MODE ---
    if (editData != null) {
      selectedItemType.value = editData!.itemType;
      date.value = DateTime.parse(editData!.date);
      quantity.value = editData!.quantity;
      weight1.value = editData!.weight1 ?? 0.0;
      weight2.value = editData!.weight2 ?? 0.0;
      rate.value = editData!.rate;
      selectedTraderId.value = editData!.traderId;

      if (quantity.value > 0)
        quantityController.text = quantity.value.toString();
      if (rate.value > 0) rateController.text = rate.value.toString();
      if (weight1.value > 0) weight1Controller.text = weight1.value.toString();
      if (weight2.value > 0) weight2Controller.text = weight2.value.toString();
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    rateController.dispose();
    weight1Controller.dispose();
    weight2Controller.dispose();
    super.onClose();
  }

  void _loadTradersForType() async {
    selectedTraderId.value = null;
    weight1Controller.clear();
    weight2Controller.clear();
    weight1.value = 0.0;
    weight2.value = 0.0;

    if (selectedItemType.value == 'Broiler' ||
        selectedItemType.value == 'Desi') {
      availableTraders.value = await _traderRepo.getTradersByCategory(
        selectedItemType.value,
      );
    } else {
      availableTraders.clear();
    }
  }

  // --- Date Picker Logic ---
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

  // --- Mutually Exclusive Validation Logic ---
  void onWeight1Changed(String val) {
    weight1.value = double.tryParse(val) ?? 0.0;
    if (weight1.value > 0) {
      weight2Controller.clear();
      weight2.value = 0.0;
    }
  }

  void onWeight2Changed(String val) {
    weight2.value = double.tryParse(val) ?? 0.0;
    if (weight2.value > 0) {
      weight1Controller.clear();
      weight1.value = 0.0;
    }
  }

  // Reactive Amount Calculation
  double get calculatedAmount {
    if (selectedItemType.value == 'Broiler' ||
        selectedItemType.value == 'Desi') {
      return (weight1.value + weight2.value) * rate.value;
    } else {
      return quantity.value * rate.value;
    }
  }

  // --- NEW: Master Validation Logic ---
  bool _isValid() {
    if (quantity.value <= 0) {
      _showError('Please enter a valid Quantity.');
      return false;
    }
    if (rate.value <= 0) {
      _showError('Please enter a valid Rate.');
      return false;
    }
    if (selectedItemType.value == 'Broiler' ||
        selectedItemType.value == 'Desi') {
      if (weight1.value <= 0 && weight2.value <= 0) {
        _showError('Please enter either Small/DP Weight or Big/OG Weight.');
        return false;
      }
      if (selectedTraderId.value == null) {
        _showError('Please select a Trader.');
        return false;
      }
    }
    return true;
  }

  // Helper for error snackbars
  void _showError(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      backgroundColor: Colors.red.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  // --- Save Function ---
  Future<void> savePurchase() async {
    if (!_isValid()) return;

    final purchase = PurchaseModel(
      id: editData?.id, // Keep ID if editing, null if creating
      shopCode: shopCode,
      itemType: selectedItemType.value,
      date: date.value.toIso8601String(),
      quantity: quantity.value,
      weight1: weight1.value,
      weight2: weight2.value,
      rate: rate.value,
      amount: calculatedAmount,
      traderId: selectedTraderId.value,
    );

    if (editData != null) {
      await _purchaseRepo.updatePurchase(purchase);
      Get.back(); // Return to reports instantly after editing
    } else {
      await _purchaseRepo.addPurchase(purchase);
      Get.snackbar(
        'Success',
        'Purchase saved.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      // Reset logic...
      quantity.value = 0;
      rate.value = 0.0;
      weight1.value = 0.0;
      weight2.value = 0.0;
      selectedTraderId.value = null;

      // Clear the text fields visually
      quantityController.clear();
      rateController.clear();
      weight1Controller.clear();
      weight2Controller.clear();
    }
  }
}
