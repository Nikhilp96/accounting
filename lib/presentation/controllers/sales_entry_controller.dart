import 'package:accounting/core/utils/backup_service.dart';
import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class SalesEntryController extends GetxController {
  late final String shopCode;
  SaleModel? editData;
  var muttonOpeningWt = 0.0.obs;
  var muttonClosingWt = 0.0.obs;

  SalesEntryController() {
    final args = Get.arguments;
    if (args is Map) {
      shopCode = args['shopCode'];
      editData = args['sale'];
    } else {
      shopCode = args ?? 'Unknown';
    }
  }

  // Inject repositories
  final SalesRepository _salesRepo = SalesRepository();
  final RateRepository _rateRepo = RateRepository();

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

  // --- Observables ---
  var broilerWt = 0.0.obs;
  var muttonWt = 0.0.obs;
  var dpWt = 0.0.obs;
  var ogWt = 0.0.obs;
  var eggQty = 0.obs;
  var potaKalejiWt = 0.0.obs;
  var userTotalAmount = 0.0.obs;

  var rateBroiler = 0.0.obs;
  var rateMutton = 0.0.obs;
  var rateDP = 0.0.obs;
  var rateOG = 0.0.obs;
  var rateEggsDozen = 0.0.obs;
  var ratePotaKaleji = 0.0.obs;

  // --- Text Controllers for Edit Mode & Overrides ---
  final wtBroilerCtrl = TextEditingController();
  final wtMuttonCtrl = TextEditingController();
  final wtDPCtrl = TextEditingController();
  final wtOGCtrl = TextEditingController();
  final qtyEggsCtrl = TextEditingController();
  final wtPotaCtrl = TextEditingController();
  final totalAmountCtrl = TextEditingController();

  final rateBroilerCtrl = TextEditingController();
  final rateMuttonCtrl = TextEditingController();
  final rateDPCtrl = TextEditingController();
  final rateOGCtrl = TextEditingController();
  final rateEggsCtrl = TextEditingController();
  final ratePotaCtrl = TextEditingController();

  final wtMuttonOpeningCtrl = TextEditingController();
  final wtMuttonClosingCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    wtBroilerCtrl.dispose();
    rateBroilerCtrl.dispose();
    // Dispose others as needed...
    super.onClose();
  }

  Future<void> _initializeData() async {
    // 1. Load Master Rates from Settings DB
    final rates = await _rateRepo.getAllRates();
    for (var r in rates) {
      if (r.itemName == 'Broiler') {
        rateBroiler.value = r.rate;
        rateBroilerCtrl.text = r.rate.toString();
      } else if (r.itemName == 'Mutton') {
        rateMutton.value = r.rate;
        rateMuttonCtrl.text = r.rate.toString();
      } else if (r.itemName == 'DP') {
        rateDP.value = r.rate;
        rateDPCtrl.text = r.rate.toString();
      } else if (r.itemName == 'OG') {
        rateOG.value = r.rate;
        rateOGCtrl.text = r.rate.toString();
      } else if (r.itemName == 'Eggs') {
        rateEggsDozen.value = r.rate;
        rateEggsCtrl.text = r.rate.toString();
      } else if (r.itemName == 'Pota Kalegi') {
        ratePotaKaleji.value = r.rate;
        ratePotaCtrl.text = r.rate.toString();
      }
    }

    // 2. Pre-fill data if Editing an existing record
    if (editData != null) {
      date.value = DateTime.parse(editData!.date);

      broilerWt.value = editData!.broilerWt;
      muttonWt.value = editData!.muttonWt;
      dpWt.value = editData!.dpWt;
      ogWt.value = editData!.ogWt;
      eggQty.value = editData!.eggQty;
      potaKalejiWt.value = editData!.potaKalejiWt;
      userTotalAmount.value = editData!.totalAmount;

      muttonOpeningWt.value = editData!.muttonOpeningWt;
      muttonClosingWt.value = editData!.muttonClosingWt;
      if (muttonOpeningWt.value > 0) {
        wtMuttonOpeningCtrl.text = muttonOpeningWt.value.toString();
      }
      if (muttonClosingWt.value > 0) {
        wtMuttonClosingCtrl.text = muttonClosingWt.value.toString();
      }

      if (broilerWt.value > 0) {
        wtBroilerCtrl.text = broilerWt.value.toString();
      }
      if (muttonWt.value > 0) {
        wtMuttonCtrl.text = muttonWt.value.toString();
      }
      if (dpWt.value > 0) {
        wtDPCtrl.text = dpWt.value.toString();
      }
      if (ogWt.value > 0) {
        wtOGCtrl.text = ogWt.value.toString();
      }
      if (eggQty.value > 0) {
        qtyEggsCtrl.text = eggQty.value.toString();
      }
      if (potaKalejiWt.value > 0) {
        wtPotaCtrl.text = potaKalejiWt.value.toString();
      }
      if (userTotalAmount.value > 0) {
        totalAmountCtrl.text = userTotalAmount.value.toString();
      }
    }
  }

  // --- REACTIVE CALCULATIONS ---
  double get calculatedSellingAmount {
    // New Mutton Formula
    double muttonBillableWt =
        (muttonWt.value / 1.6) + muttonOpeningWt.value - muttonClosingWt.value;
    // Prevent negative billable weight
    if (muttonBillableWt < 0) muttonBillableWt = 0;

    return (broilerWt.value * rateBroiler.value) +
        (muttonBillableWt * rateMutton.value) + // <-- Use billable weight here
        (dpWt.value * rateDP.value) +
        (ogWt.value * rateOG.value) +
        ((eggQty.value / 12) * rateEggsDozen.value) +
        (potaKalejiWt.value * ratePotaKaleji.value);
  }

  double get differenceAmount =>
      userTotalAmount.value - calculatedSellingAmount;

  // --- DB INSERTION ---
  Future<void> saveWeeklySale() async {
    if (userTotalAmount.value <= 0 && calculatedSellingAmount > 0) {
      Get.snackbar(
        'Validation Error',
        'Please enter the Total Amount Collected.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
      return;
    }

    final sale = SaleModel(
      id: editData?.id,
      shopCode: shopCode,
      date: date.value.toIso8601String(),
      broilerWt: broilerWt.value,
      muttonOpeningWt: muttonOpeningWt.value, // <-- Add this
      muttonClosingWt: muttonClosingWt.value, // <-- Add this
      muttonWt: muttonWt.value,
      dpWt: dpWt.value,
      ogWt: ogWt.value,
      eggQty: eggQty.value,
      potaKalejiWt: potaKalejiWt.value,
      sellingAmount: calculatedSellingAmount, // Safely stores hard math
      totalAmount: userTotalAmount.value,
      difference: differenceAmount,
    );

    if (editData != null) {
      await _salesRepo.updateSale(sale);
      await BackupService.exportToExcel();
      Get.back();
    } else {
      await _salesRepo.addSale(sale);
      await BackupService.exportToExcel();
    }

    Get.snackbar(
      'Success',
      'Sales saved for Shop $shopCode on ${DateUtil.format(date.value)}',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }
}
