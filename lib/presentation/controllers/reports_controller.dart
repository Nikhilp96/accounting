import 'package:accounting/core/utils/backup_service.dart';
import 'package:accounting/core/utils/date_util.dart';
import 'package:accounting/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:accounting/core/utils/report_export_service.dart';
import 'dart:io';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class ReportsController extends GetxController {
  final String shopCode = Get.arguments ?? 'Unknown';

  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  final SalesRepository _salesRepo = SalesRepository();
  final TraderRepository _traderRepo = TraderRepository();
  final StockRepository _stockRepo = StockRepository(); // Inject Stock Repo

  var viewMode = 'Weekly'.obs;
  var activeTab = 'Purchases'.obs;
  var selectedDate = DateTime.now().obs;
  var isLoading = false.obs;

  var purchasesList = <PurchaseModel>[].obs;
  var salesList = <SaleModel>[].obs;
  var traderMap = <int, String>{}.obs;

  // Observable Map to hold all UI text inputs for stock
  var stockMap = <String, dynamic>{}.obs;

  final ExpenseRepository _expenseRepo = ExpenseRepository();
  var expensesList = <ExpenseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTraders();
    fetchData();
    ever(viewMode, (_) => fetchData());
    ever(selectedDate, (_) => fetchData());
  }

  DateTime get _startDate {
    DateTime d = selectedDate.value;
    if (viewMode.value == 'Daily') {
      return DateTime(d.year, d.month, d.day, 0, 0, 0);
    }
    return d
        .subtract(Duration(days: d.weekday - 1))
        .copyWith(hour: 0, minute: 0, second: 0);
  }

  DateTime get _endDate {
    DateTime d = selectedDate.value;
    if (viewMode.value == 'Daily') {
      return DateTime(d.year, d.month, d.day, 23, 59, 59);
    }
    DateTime startOfWeek = d.subtract(Duration(days: d.weekday - 1));
    return startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  }

  String get dateDisplay {
    if (viewMode.value == 'Daily') return DateUtil.format(selectedDate.value);
    return "${DateUtil.format(_startDate)} to ${DateUtil.format(_endDate)}";
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
      expensesList.value = await _expenseRepo.getExpensesByRange(
        shopCode,
        startIso,
        endIso,
      );
      await _loadStockData(); // Load balances
    } finally {
      isLoading.value = false;
    }
  }

  // Fetches historical stock balances for the selected date range
  Future<void> _loadStockData() async {
    stockMap.clear();
    String startIso = _startDate.toIso8601String().split('T')[0];
    String endIso = _endDate.toIso8601String().split('T')[0];

    List<String> categories = ['Broiler', 'Desi', 'Eggs', 'Pota Kalegi'];
    for (var cat in categories) {
      var openStock = await _stockRepo.getStock(shopCode, startIso, cat);
      if (openStock != null) {
        stockMap['Opening_${cat}_Qty'] = openStock.qty;
        stockMap['Opening_${cat}_Wt1'] = openStock.weight1;
        stockMap['Opening_${cat}_Wt2'] = openStock.weight2;
      }

      var closeStock = await _stockRepo.getStock(shopCode, endIso, cat);
      if (closeStock != null) {
        stockMap['Closing_${cat}_Qty'] = closeStock.qty;
        stockMap['Closing_${cat}_Wt1'] = closeStock.weight1;
        stockMap['Closing_${cat}_Wt2'] = closeStock.weight2;
      }
    }
  }

  // Saves the inputs back to the database
  Future<void> saveStockData(String itemType) async {
    String startIso = _startDate.toIso8601String().split('T')[0];
    String endIso = _endDate.toIso8601String().split('T')[0];

    final openStock = StockModel(
      shopCode: shopCode,
      date: startIso,
      itemType: itemType,
      qty: stockMap['Opening_${itemType}_Qty'] ?? 0,
      weight1: stockMap['Opening_${itemType}_Wt1'] ?? 0.0,
      weight2: stockMap['Opening_${itemType}_Wt2'] ?? 0.0,
    );
    await _stockRepo.saveStock(openStock);

    final closeStock = StockModel(
      shopCode: shopCode,
      date: endIso,
      itemType: itemType,
      qty: stockMap['Closing_${itemType}_Qty'] ?? 0,
      weight1: stockMap['Closing_${itemType}_Wt1'] ?? 0.0,
      weight2: stockMap['Closing_${itemType}_Wt2'] ?? 0.0,
    );
    await _stockRepo.saveStock(closeStock);
    await BackupService.exportToExcel();
    Get.snackbar(
      'Saved',
      '$itemType balances updated successfully.',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  // --- Deletes & Edits ---
  Future<void> deletePurchaseRecord(int id) async {
    await _purchaseRepo.deletePurchase(id);
    await BackupService.exportToExcel();
    fetchData();
    Get.snackbar(
      'Deleted',
      'Purchase record removed.',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }

  Future<void> deleteSalesRecord(int id) async {
    await _salesRepo.deleteSale(id);
    await BackupService.exportToExcel();
    fetchData();
    Get.snackbar(
      'Deleted',
      'Sales record removed.',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }

  void editPurchase(PurchaseModel purchase) {
    Get.toNamed(
      '/purchase-entry',
      arguments: {'shopCode': shopCode, 'purchase': purchase},
    )?.then((_) {
      fetchData();
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

  // --- Analysis ---
  double get totalPurchases =>
      purchasesList.fold(0.0, (sum, item) => sum + item.amount);
  double get totalSystemSales =>
      salesList.fold(0.0, (sum, item) => sum + item.sellingAmount);
  double get totalCollectedSales =>
      salesList.fold(0.0, (sum, item) => sum + item.totalAmount);
  double get salesDifference =>
      salesList.fold(0.0, (sum, item) => sum + item.difference);
  double get totalWeeklyExpenses =>
      expensesList.fold(0.0, (sum, item) => sum + item.amount);
  double get netPosition =>
      totalCollectedSales - totalPurchases - totalWeeklyExpenses;

  Future<void> _loadTraders() async {
    final traders = await _traderRepo.getAllTraders();
    for (var t in traders) {
      if (t.id != null) traderMap[t.id!] = t.name;
    }
  }

  Map<String, Map<String, double>> get birdsEyeView {
    Map<String, Map<String, double>> summary = {
      'Broiler': {'Purchase': 0.0, 'Sales': 0.0, 'Difference': 0.0},
      'DP': {'Purchase': 0.0, 'Sales': 0.0, 'Difference': 0.0},
      'OG': {'Purchase': 0.0, 'Sales': 0.0, 'Difference': 0.0},
    };

    // 1. Calculate Purchases (Actual Consumption = Pur + Open - Close)
    // Broiler
    double bPur1 = purchasesList
        .where((p) => p.itemType == 'Broiler')
        .fold(0.0, (s, p) => s + (p.weight1 ?? 0.0));
    double bPur2 = purchasesList
        .where((p) => p.itemType == 'Broiler')
        .fold(0.0, (s, p) => s + (p.weight2 ?? 0.0));
    summary['Broiler']!['Purchase'] =
        (bPur1 +
            (stockMap['Opening_Broiler_Wt1'] ?? 0.0) -
            (stockMap['Closing_Broiler_Wt1'] ?? 0.0)) +
        (bPur2 +
            (stockMap['Opening_Broiler_Wt2'] ?? 0.0) -
            (stockMap['Closing_Broiler_Wt2'] ?? 0.0));

    // DP
    double dPur = purchasesList
        .where((p) => p.itemType == 'Desi')
        .fold(0.0, (s, p) => s + (p.weight1 ?? 0.0));
    summary['DP']!['Purchase'] =
        (dPur +
        (stockMap['Opening_Desi_Wt1'] ?? 0.0) -
        (stockMap['Closing_Desi_Wt1'] ?? 0.0));

    // OG
    double oPur = purchasesList
        .where((p) => p.itemType == 'Desi')
        .fold(0.0, (s, p) => s + (p.weight2 ?? 0.0));
    summary['OG']!['Purchase'] =
        (oPur +
        (stockMap['Opening_Desi_Wt2'] ?? 0.0) -
        (stockMap['Closing_Desi_Wt2'] ?? 0.0));

    // 2. Calculate Sales
    double totalBroilerSales = salesList.fold(0.0, (s, i) => s + i.broilerWt);
    double totalMuttonSales = salesList.fold(0.0, (s, i) => s + i.muttonWt);
    double totalDpSales = salesList.fold(0.0, (s, i) => s + i.dpWt);
    double totalOgSales = salesList.fold(0.0, (s, i) => s + i.ogWt);

    summary['Broiler']!['Sales'] = totalBroilerSales + totalMuttonSales;
    summary['DP']!['Sales'] = totalDpSales;
    summary['OG']!['Sales'] = totalOgSales;

    // 3. Difference (Formula: Sales - Purchase)
    // Positive = Surplus, Negative = Deficit
    summary['Broiler']!['Difference'] =
        summary['Broiler']!['Sales']! - summary['Broiler']!['Purchase']!;
    summary['DP']!['Difference'] =
        summary['DP']!['Sales']! - summary['DP']!['Purchase']!;
    summary['OG']!['Difference'] =
        summary['OG']!['Sales']! - summary['OG']!['Purchase']!;

    return summary;
  }

  // --- Trader Payables Calculation ---
  Map<String, double> get traderPayables {
    Map<String, double> payables = {};

    for (var purchase in purchasesList) {
      String key;
      // 1. Check if a specific trader was assigned
      if (purchase.traderId != null &&
          traderMap.containsKey(purchase.traderId)) {
        key = traderMap[purchase.traderId!]!;
      } else {
        // 2. Fallback to the Item Category (e.g., 'Eggs', 'Pota Kalegi')
        key = purchase.itemType;
      }

      // Add the purchase amount to that specific key's running total
      payables[key] = (payables[key] ?? 0.0) + purchase.amount;
    }

    return payables;
  }

  Future<void> deleteExpenseRecord(int id) async {
    await _expenseRepo.deleteExpense(id);
    await BackupService.exportToExcel();
    fetchData();
    Get.snackbar(
      'Deleted',
      'Expense record removed.',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }

  void editExpense(ExpenseModel expense) {
    // Assuming you registered the route in app_routes.dart as '/expense-entry'.
    // If not, you can use: Get.to(() => const ExpenseEntryPage(), arguments: {'shopCode': shopCode, 'expense': expense})?.then((_) { fetchData(); });
    Get.toNamed(
      Routes.EXPENSE_ENTRY, // Adjust to your actual route name if different
      arguments: {'shopCode': shopCode, 'expense': expense},
    )?.then((_) {
      fetchData();
    });
  }

  Future<void> exportReportToExcel() async {
    try {
      String savedPath = await ReportExportService.exportReport(
        shopCode: shopCode,
        startDate: _startDate,
        endDate: _endDate,
        purchases: purchasesList,
        sales: salesList,
        expenses: expensesList,
        traderPayables: traderPayables,
        birdsEyeView: birdsEyeView,
        totalCollected: totalCollectedSales,
        totalPurchases: totalPurchases,
        totalExpenses: totalWeeklyExpenses,
        netPosition: netPosition,
      );

      Get.snackbar(
        'Export Successful',
        'Saved to: $savedPath',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        duration: const Duration(
          seconds: 4,
        ), // Longer duration to read the path
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        e.toString(),
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
