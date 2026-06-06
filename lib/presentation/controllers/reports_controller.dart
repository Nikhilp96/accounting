import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class ReportsController extends GetxController {
  final String shopCode = Get.arguments ?? 'Unknown';

  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  final SalesRepository _salesRepo = SalesRepository();
  final TraderRepository _traderRepo = TraderRepository();

  // Filters
  var viewMode = 'Daily'.obs; // 'Daily' or 'Weekly'
  var activeTab = 'Purchases'.obs; // 'Purchases' or 'Sales'
  var selectedDate = DateTime.now().obs;

  var isLoading = false.obs;

  // Data
  var purchasesList = <PurchaseModel>[].obs;
  var salesList = <SaleModel>[].obs;
  var traderMap = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTraders();
    fetchData();
    // Reactively fetch data whenever the view mode or selected date changes
    ever(viewMode, (_) => fetchData());
    ever(selectedDate, (_) => fetchData());
  }

  // --- Date Math ---
  DateTime get _startDate {
    DateTime d = selectedDate.value;
    if (viewMode.value == 'Daily') {
      return DateTime(d.year, d.month, d.day, 0, 0, 0);
    } else {
      // Find the Monday of the current week
      return d
          .subtract(Duration(days: d.weekday - 1))
          .copyWith(hour: 0, minute: 0, second: 0);
    }
  }

  DateTime get _endDate {
    DateTime d = selectedDate.value;
    if (viewMode.value == 'Daily') {
      return DateTime(d.year, d.month, d.day, 23, 59, 59);
    } else {
      // Find the Sunday of the current week
      DateTime startOfWeek = d.subtract(Duration(days: d.weekday - 1));
      return startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
    }
  }

  String get dateDisplay {
    if (viewMode.value == 'Daily') {
      return DateUtil.format(selectedDate.value);
    } else {
      return "${DateUtil.format(_startDate)} to ${DateUtil.format(_endDate)}";
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      String startIso = _startDate.toIso8601String();
      String endIso = _endDate.toIso8601String();

      purchasesList.value = await _purchaseRepo.getPurchasesByDateRange(
        shopCode,
        startIso,
        endIso,
      );
      salesList.value = await _salesRepo.getSalesByDateRange(
        shopCode,
        startIso,
        endIso,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePurchaseRecord(int id) async {
    await _purchaseRepo.deletePurchase(id);
    fetchData(); // Refresh the table
    Get.snackbar(
      'Deleted',
      'Purchase record removed and backup updated.',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }

  Future<void> deleteSalesRecord(int id) async {
    await _salesRepo.deleteSale(id);
    fetchData(); // Refresh the table
    Get.snackbar(
      'Deleted',
      'Sales record removed and backup updated.',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }

  void editPurchase(PurchaseModel purchase) {
    // Navigate to Entry page, passing both shopCode and the model
    Get.toNamed(
      '/purchase-entry',
      arguments: {'shopCode': shopCode, 'purchase': purchase},
    )?.then((_) {
      fetchData(); // Refresh data when returning from the edit screen
    });
  }

  void editSale(SaleModel sale) {
    Get.toNamed(
      '/sales-entry',
      arguments: {'shopCode': shopCode, 'sale': sale},
    )?.then((_) {
      fetchData();
    });
  }

  // --- Analysis Calculations ---
  double get totalPurchases =>
      purchasesList.fold(0.0, (sum, item) => sum + item.amount);
  double get totalSystemSales =>
      salesList.fold(0.0, (sum, item) => sum + item.sellingAmount);
  double get totalCollectedSales =>
      salesList.fold(0.0, (sum, item) => sum + item.totalAmount);
  double get salesDifference =>
      salesList.fold(0.0, (sum, item) => sum + item.difference);

  // Net Position indicator (Collected Cash - Cash Spent on Purchases)
  double get netPosition => totalCollectedSales - totalPurchases;

  Future<void> _loadTraders() async {
    final traders = await _traderRepo.getAllTraders();
    for (var t in traders) {
      if (t.id != null) {
        traderMap[t.id!] = t.name;
      }
    }
  }
}
