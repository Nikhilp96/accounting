import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class SalesEntryController extends GetxController {
  late final String shopCode;
  SaleModel? editData;

  SalesEntryController() {
    final args = Get.arguments;
    if (args is Map) {
      shopCode = args['shopCode'];
      editData = args['sale'];
    } else {
      shopCode = args ?? 'Unknown';
    }
  }

  @override
  void onInit() {
    super.onInit();

    // --- PRE-FILL DATA FOR EDIT MODE ---
    if (editData != null) {
      date.value = DateTime.parse(editData!.date);
      broilerWt.value = editData!.broilerWt;
      muttonWt.value = editData!.muttonWt;
      dpWt.value = editData!.dpWt;
      ogWt.value = editData!.ogWt;
      eggQty.value = editData!.eggQty;
      potaKalejiWt.value = editData!.potaKalejiWt;
      userTotalAmount.value = editData!.totalAmount;
    }
  } 

  // Inject the repository to handle database operations
  final SalesRepository _salesRepo = SalesRepository();

  var date = DateTime.now().obs;

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

  // Input Observables (Bound to UI TextFields)
  var broilerWt = 0.0.obs;
  var muttonWt = 0.0.obs;
  var dpWt = 0.0.obs;
  var ogWt = 0.0.obs;
  var eggQty = 0.obs; // In pieces
  var potaKalejiWt = 0.0.obs;
  var userTotalAmount = 0.0.obs; // The amount you manually enter

  // Master Rates
  var rateBroiler = 180.0.obs;
  var rateMutton = 280.0.obs;
  var rateDP = 260.0.obs;
  var rateOG = 530.0.obs;
  var rateEggsDozen = 80.0.obs;
  var ratePotaKaleji = 200.0.obs;

  // --- REACTIVE CALCULATIONS ---

  // Calculated Automatically: Selling Amount
  double get calculatedSellingAmount {
    double broilerTotal = broilerWt.value * rateBroiler.value;
    double muttonTotal = muttonWt.value * rateMutton.value;
    double dpTotal = dpWt.value * rateDP.value;
    double ogTotal = ogWt.value * rateOG.value;

    // Note on Eggs: Rate is per dozen, quantity is per piece.
    double eggTotal = (eggQty.value / 12) * rateEggsDozen.value;

    double potaTotal = potaKalejiWt.value * ratePotaKaleji.value;

    return broilerTotal +
        muttonTotal +
        dpTotal +
        ogTotal +
        eggTotal +
        potaTotal;
  }

  // Calculated Automatically: Difference
  double get differenceAmount {
    return userTotalAmount.value - calculatedSellingAmount;
  }

  // --- DB INSERTION ---
  Future<void> saveWeeklySale() async {
    // 1. Validation: Ensure a total collected amount has been entered
    if (userTotalAmount.value <= 0 && calculatedSellingAmount > 0) {
      Get.snackbar(
        'Validation Error',
        'Please enter the Total Amount Collected.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }

    // 2. Map the reactive variables to the SQLite Model
    final sale = SaleModel(
      id: editData?.id,
      shopCode: shopCode,
      date: date.value.toIso8601String(),
      broilerWt: broilerWt.value,
      muttonWt: muttonWt.value,
      dpWt: dpWt.value,
      ogWt: ogWt.value,
      eggQty: eggQty.value,
      potaKalejiWt: potaKalejiWt.value,
      sellingAmount: calculatedSellingAmount,
      totalAmount: userTotalAmount.value,
      difference: differenceAmount,
    );

    // 3. Insert into Database
    if (editData != null) {
      await _salesRepo.updateSale(sale);
      Get.back(); // Return to reports
    } else {
      await _salesRepo.addSale(sale);
    }

    // 4. Success Notification
    Get.snackbar(
      'Success',
      'Data saved for Shop $shopCode on ${DateUtil.format(date.value)}', // Updated here
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
