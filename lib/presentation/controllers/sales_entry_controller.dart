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
  var broilerQty = 0.obs; // Added

  var muttonWt = 0.0.obs;
  var muttonQty = 0.obs; // Added

  var dpWt = 0.0.obs;
  var dpQty = 0.obs; // Added

  var ogWt = 0.0.obs;
  var ogQty = 0.obs; // Added

  var eggQty = 0.obs;

  var potaKalejiWt = 0.0.obs;
  var potaKalejiQty = 0.obs; // Added

  var userTotalAmount = 0.0.obs;

  var rateBroiler = 0.0.obs;
  var rateMutton = 0.0.obs;
  var rateDP = 0.0.obs;
  var rateOG = 0.0.obs;
  var rateEggsDozen = 0.0.obs;
  var ratePotaKaleji = 0.0.obs;
  // --- ADD MORTALITY OBSERVABLES ---
  var broilerDeadQty = 0.obs;
  var broilerDeadWt = 0.0.obs;
  var dpDeadQty = 0.obs;
  var dpDeadWt = 0.0.obs;
  var ogDeadQty = 0.obs;
  var ogDeadWt = 0.0.obs;

  // --- Text Controllers for Edit Mode & Overrides ---
  final wtBroilerCtrl = TextEditingController();
  final qtyBroilerCtrl = TextEditingController(); // Added

  final wtMuttonCtrl = TextEditingController();
  final qtyMuttonCtrl = TextEditingController(); // Added

  final wtDPCtrl = TextEditingController();
  final qtyDPCtrl = TextEditingController(); // Added

  final wtOGCtrl = TextEditingController();
  final qtyOGCtrl = TextEditingController(); // Added

  final qtyEggsCtrl = TextEditingController();

  final wtPotaCtrl = TextEditingController();
  final qtyPotaCtrl = TextEditingController();
  final totalAmountCtrl = TextEditingController();
  final qtyBroilerDeadCtrl = TextEditingController();
  final wtBroilerDeadCtrl = TextEditingController();
  final qtyDPDeadCtrl = TextEditingController();
  final wtDPDeadCtrl = TextEditingController();
  final qtyOGDeadCtrl = TextEditingController();
  final wtOGDeadCtrl = TextEditingController();

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
      broilerQty.value = editData!.broilerQty;
      muttonQty.value = editData!.muttonQty;
      dpQty.value = editData!.dpQty;
      ogQty.value = editData!.ogQty;
      potaKalejiQty.value = editData!.potaKalejiQty;
      if (broilerQty.value > 0) {
        qtyBroilerCtrl.text = broilerQty.value.toString();
      }
      if (muttonQty.value > 0) qtyMuttonCtrl.text = muttonQty.value.toString();
      if (dpQty.value > 0) qtyDPCtrl.text = dpQty.value.toString();
      if (ogQty.value > 0) qtyOGCtrl.text = ogQty.value.toString();
      if (potaKalejiQty.value > 0) {
        qtyPotaCtrl.text = potaKalejiQty.value.toString();
      }

      broilerDeadQty.value = editData!.broilerDeadQty;
      broilerDeadWt.value = editData!.broilerDeadWt;
      dpDeadQty.value = editData!.dpDeadQty;
      dpDeadWt.value = editData!.dpDeadWt;
      ogDeadQty.value = editData!.ogDeadQty;
      ogDeadWt.value = editData!.ogDeadWt;
      
      if (broilerDeadQty.value > 0) qtyBroilerDeadCtrl.text = broilerDeadQty.value.toString();
      if (broilerDeadWt.value > 0) wtBroilerDeadCtrl.text = broilerDeadWt.value.toString();
      if (dpDeadQty.value > 0) qtyDPDeadCtrl.text = dpDeadQty.value.toString();
      if (dpDeadWt.value > 0) wtDPDeadCtrl.text = dpDeadWt.value.toString();
      if (ogDeadQty.value > 0) qtyOGDeadCtrl.text = ogDeadQty.value.toString();
      if (ogDeadWt.value > 0) wtOGDeadCtrl.text = ogDeadWt.value.toString();
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
      broilerQty: broilerQty.value,
      muttonOpeningWt: muttonOpeningWt.value, // <-- Add this
      muttonClosingWt: muttonClosingWt.value, // <-- Add this
      muttonQty: muttonQty.value,
      muttonWt: muttonWt.value,
      dpQty: dpQty.value,
      dpWt: dpWt.value,
      ogQty: ogQty.value,
      ogWt: ogWt.value,
      eggQty: eggQty.value,
      potaKalejiQty: potaKalejiQty.value,
      potaKalejiWt: potaKalejiWt.value,
      sellingAmount: calculatedSellingAmount, // Safely stores hard math
      totalAmount: userTotalAmount.value,
      difference: differenceAmount,
      broilerDeadQty: broilerDeadQty.value,
      broilerDeadWt: broilerDeadWt.value,
      dpDeadQty: dpDeadQty.value,
      dpDeadWt: dpDeadWt.value,
      ogDeadQty: ogDeadQty.value,
      ogDeadWt: ogDeadWt.value,
    );

    if (editData != null) {
      await _salesRepo.updateSale(sale);
      await BackupService.exportToExcel();
      Get.back();
    } else {
      await _salesRepo.addSale(sale);
      await BackupService.exportToExcel();
      _resetFields();
    }

    Get.snackbar(
      'Success',
      'Sales saved for Shop $shopCode on ${DateUtil.format(date.value)}',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  void _resetFields() {
    // Reset Observables
    broilerQty.value = 0;
    broilerWt.value = 0.0;
    muttonQty.value = 0;
    muttonWt.value = 0.0;
    dpQty.value = 0;
    dpWt.value = 0.0;
    ogQty.value = 0;
    ogWt.value = 0.0;
    potaKalejiQty.value = 0;
    potaKalejiWt.value = 0.0;
    eggQty.value = 0;
    userTotalAmount.value = 0.0;
    muttonOpeningWt.value = 0.0;
    muttonClosingWt.value = 0.0;
    date.value = DateTime.now();

    // Clear Text Fields
    qtyBroilerCtrl.clear();
    wtBroilerCtrl.clear();
    qtyMuttonCtrl.clear();
    wtMuttonCtrl.clear();
    qtyDPCtrl.clear();
    wtDPCtrl.clear();
    qtyOGCtrl.clear();
    wtOGCtrl.clear();
    qtyPotaCtrl.clear();
    wtPotaCtrl.clear();
    qtyEggsCtrl.clear();
    totalAmountCtrl.clear();
    wtMuttonOpeningCtrl.clear();
    wtMuttonClosingCtrl.clear();

    broilerDeadQty.value = 0; broilerDeadWt.value = 0.0;
    dpDeadQty.value = 0; dpDeadWt.value = 0.0;
    ogDeadQty.value = 0; ogDeadWt.value = 0.0;
    qtyBroilerDeadCtrl.clear(); wtBroilerDeadCtrl.clear();
    qtyDPDeadCtrl.clear(); wtDPDeadCtrl.clear();
    qtyOGDeadCtrl.clear(); wtOGDeadCtrl.clear();

    // (Notice we DO NOT reset the rate fields, as those stay cached for convenience!)
  }
}
