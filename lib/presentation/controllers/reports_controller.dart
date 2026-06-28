import 'package:accounting/core/utils/backup_manager.dart';
import 'package:accounting/core/utils/date_util.dart';
import 'package:accounting/core/cache/app_cache.dart';
import 'package:accounting/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:accounting/core/utils/report_export_service.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class ReportsController extends GetxController {
  var shopCode = 'NK'.obs;
  final List<String> availableShops = ['NK', 'NP', 'PT'];

  final PurchaseRepository _purchaseRepo = Get.find<PurchaseRepository>();
  final SalesRepository _salesRepo = Get.find<SalesRepository>();
  final StockRepository _stockRepo = Get.find<StockRepository>();
  final ExpenseRepository _expenseRepo = Get.find<ExpenseRepository>();

  var viewMode = 'Weekly'.obs;
  var activeTab = 'Purchases'.obs;
  var selectedDate = DateTime.now().obs;
  var isLoading = false.obs;

  var purchasesList = <PurchaseModel>[].obs;
  var salesList = <SaleModel>[].obs;
  var traderMap = <int, String>{}.obs;

  // Observable Map to hold all UI text inputs for stock
  var stockMap = <String, dynamic>{}.obs;

  final TransferRepository _transferRepo = Get.find<TransferRepository>();
  var transfersList = <TransferModel>[].obs;

  var expensesList = <ExpenseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Check if a specific shop was passed, otherwise default to 'NK'
    String arg = Get.arguments?.toString() ?? 'NK';
    if (availableShops.contains(arg)) {
      shopCode.value = arg;
    } else {
      shopCode.value = 'NK'; // Default fallback for 'ALL'
    }
    _loadTraders();
    fetchData();
    ever(viewMode, (_) => fetchData());
    ever(selectedDate, (_) => fetchData());
    ever(shopCode, (_) => fetchData());
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

      // Parallelize all independent queries using Future.wait
      final results = await Future.wait([
        _purchaseRepo.getPurchasesByDateRange(shopCode.value, startIso, endIso),
        _salesRepo.getSalesByDateRange(shopCode.value, startIso, endIso),
        _expenseRepo.getExpensesByRange(shopCode.value, startIso, endIso),
        _transferRepo.getTransfersForShop(shopCode.value, startIso, endIso),
        _loadStockData(),
      ]);

      purchasesList.value = results[0] as List<PurchaseModel>;
      salesList.value = results[1] as List<SaleModel>;
      expensesList.value = results[2] as List<ExpenseModel>;
      transfersList.value = results[3] as List<TransferModel>;

      await calculateSalesPieces();
    } finally {
      isLoading.value = false;
    }
  }

  // Fetches historical stock balances for the selected date range
  Future<void> _loadStockData() async {
    stockMap.clear();

    // FIX 1: Opening stock is the closing stock of the day BEFORE the period starts!
    String openDateIso = _startDate
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];
    String closeDateIso = _endDate.toIso8601String().split('T')[0];

    List<String> categories = ['Broiler', 'Desi', 'Eggs', 'Pota Kalegi'];

    for (var cat in categories) {
      // FIX 2: Fetch both Small/DP (Wt1) AND Big/OG (Wt2) rows from the database

      // Fetch Small/DP (isWt2: false)
      var open1 = await _stockRepo.getStock(
        shopCode.value,
        openDateIso,
        cat,
        isWt2: false,
      );
      var close1 = await _stockRepo.getStock(
        shopCode.value,
        closeDateIso,
        cat,
        isWt2: false,
      );

      // Fetch Big/OG (isWt2: true)
      var open2 = await _stockRepo.getStock(
        shopCode.value,
        openDateIso,
        cat,
        isWt2: true,
      );
      var close2 = await _stockRepo.getStock(
        shopCode.value,
        closeDateIso,
        cat,
        isWt2: true,
      );

      // Merge quantities and weights into the UI stockMap
      double openQty = (open1?.qty ?? 0.0) + (open2?.qty ?? 0.0);
      double closeQty = (close1?.qty ?? 0.0) + (close2?.qty ?? 0.0);

      stockMap['Opening_${cat}_Qty'] = openQty;
      stockMap['Opening_${cat}_Wt1'] = open1?.weight1 ?? 0.0;
      stockMap['Opening_${cat}_Wt2'] =
          open2?.weight2 ?? 0.0; // Now accurately populates Big Wt

      stockMap['Closing_${cat}_Qty'] = closeQty;
      stockMap['Closing_${cat}_Wt1'] = close1?.weight1 ?? 0.0;
      stockMap['Closing_${cat}_Wt2'] =
          close2?.weight2 ?? 0.0; // Now accurately populates Big Wt
    }
  }

  // --- Deletes & Edits ---
  Future<void> deletePurchaseRecord(int id) async {
    try {
      await _purchaseRepo.deletePurchase(id);
      BackupManager.instance.scheduleBackup();
      fetchData();
      Get.snackbar(
        'Deleted',
        'Purchase record removed.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete purchase: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteSalesRecord(int id) async {
    try {
      await _salesRepo.deleteSale(id);
      BackupManager.instance.scheduleBackup();
      fetchData();
      Get.snackbar(
        'Deleted',
        'Sales record removed.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete sales record: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void editPurchase(PurchaseModel purchase) {
    Get.toNamed(
      '/purchase-entry',
      arguments: {'shopCode': shopCode.value, 'purchase': purchase},
    )?.then((_) {
      fetchData();
    });
  }

  void editSale(SaleModel sale) {
    Get.toNamed(
      '/sales-entry',
      arguments: {'shopCode': shopCode.value, 'sale': sale},
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
    final map = await AppCache.instance.getTraderNameMap();
    traderMap.value = map;
  }

  Map<String, Map<String, double>> get birdsEyeView {
    Map<String, Map<String, double>> summary = {
      'Broiler': {
        'Purchase': 0.0,
        'Sales': 0.0,
        'Dead': 0.0,
        'Difference': 0.0,
      },
      'DP': {'Purchase': 0.0, 'Sales': 0.0, 'Dead': 0.0, 'Difference': 0.0},
      'OG': {'Purchase': 0.0, 'Sales': 0.0, 'Dead': 0.0, 'Difference': 0.0},
    };

    // 1. Calculate Purchases (Actual Consumption = Pur + Open - Close)
    double bPur1 = purchasesList
        .where((p) => p.itemType == 'Broiler')
        .fold(0.0, (s, p) => s + (p.weight1 ?? 0.0));
    double bPur2 = purchasesList
        .where((p) => p.itemType == 'Broiler')
        .fold(0.0, (s, p) => s + (p.weight2 ?? 0.0));
    double bNetTransfer =
        getTransferTotal('Broiler', 'Wt1', isReceived: true) +
        getTransferTotal('Broiler', 'Wt2', isReceived: true) -
        getTransferTotal('Broiler', 'Wt1', isReceived: false) -
        getTransferTotal('Broiler', 'Wt2', isReceived: false);
    summary['Broiler']!['Purchase'] =
        (bPur1 +
            (stockMap['Opening_Broiler_Wt1'] ?? 0.0) -
            (stockMap['Closing_Broiler_Wt1'] ?? 0.0)) +
        (bPur2 +
            (stockMap['Opening_Broiler_Wt2'] ?? 0.0) -
            (stockMap['Closing_Broiler_Wt2'] ?? 0.0)) +
        bNetTransfer;

    double dPur = purchasesList
        .where((p) => p.itemType == 'Desi')
        .fold(0.0, (s, p) => s + (p.weight1 ?? 0.0));
    double dNetTransfer =
        getTransferTotal('Desi', 'Wt1', isReceived: true) -
        getTransferTotal('Desi', 'Wt1', isReceived: false);
    summary['DP']!['Purchase'] =
        (dPur +
            (stockMap['Opening_Desi_Wt1'] ?? 0.0) -
            (stockMap['Closing_Desi_Wt1'] ?? 0.0)) +
        dNetTransfer;

    double oPur = purchasesList
        .where((p) => p.itemType == 'Desi')
        .fold(0.0, (s, p) => s + (p.weight2 ?? 0.0));
    double oNetTransfer =
        getTransferTotal('Desi', 'Wt2', isReceived: true) -
        getTransferTotal('Desi', 'Wt2', isReceived: false);
    summary['OG']!['Purchase'] =
        (oPur +
            (stockMap['Opening_Desi_Wt2'] ?? 0.0) -
            (stockMap['Closing_Desi_Wt2'] ?? 0.0)) +
        oNetTransfer;

    // 2. Calculate Actual Sales & Mortality
    double totalBroilerSales = salesList.fold(0.0, (s, i) => s + i.broilerWt);
    double totalMuttonSales = salesList.fold(0.0, (s, i) => s + i.muttonWt);
    summary['Broiler']!['Sales'] = totalBroilerSales + totalMuttonSales;
    summary['Broiler']!['Dead'] = salesList.fold(
      0.0,
      (s, i) => s + i.broilerDeadWt,
    );

    summary['DP']!['Sales'] = salesList.fold(0.0, (s, i) => s + i.dpWt);
    summary['DP']!['Dead'] = salesList.fold(0.0, (s, i) => s + i.dpDeadWt);

    summary['OG']!['Sales'] = salesList.fold(0.0, (s, i) => s + i.ogWt);
    summary['OG']!['Dead'] = salesList.fold(0.0, (s, i) => s + i.ogDeadWt);

    // 3. Difference Formula: (Actual Sales + Dead) - Total Purchase
    // Positive difference = Surplus. Negative difference = Shortage/Leakage.
    summary['Broiler']!['Difference'] =
        (summary['Broiler']!['Sales']! + summary['Broiler']!['Dead']!) -
        summary['Broiler']!['Purchase']!;
    summary['DP']!['Difference'] =
        (summary['DP']!['Sales']! + summary['DP']!['Dead']!) -
        summary['DP']!['Purchase']!;
    summary['OG']!['Difference'] =
        (summary['OG']!['Sales']! + summary['OG']!['Dead']!) -
        summary['OG']!['Purchase']!;

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
    try {
      await _expenseRepo.deleteExpense(id);
      BackupManager.instance.scheduleBackup();
      fetchData();
      Get.snackbar(
        'Deleted',
        'Expense record removed.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete expense: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void editExpense(ExpenseModel expense) {
    // Assuming you registered the route in app_routes.dart as '/expense-entry'.
    // If not, you can use: Get.to(() => const ExpenseEntryPage(), arguments: {'shopCode': shopCode, 'expense': expense})?.then((_) { fetchData(); });
    Get.toNamed(
      Routes.EXPENSE_ENTRY, // Adjust to your actual route name if different
      arguments: {'shopCode': shopCode.value, 'expense': expense},
    )?.then((_) {
      fetchData();
    });
  }

  Future<void> exportReportToExcel() async {
    try {
      String savedPath = await ReportExportService.exportReport(
        shopCode: shopCode.value,
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
        salesPiecesData: salesPiecesData,
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

  // Add these helper methods to calculate received/sent totals:
  double getTransferTotal(
    String itemType,
    String field, {
    required bool isReceived,
    String? otherShop, // <-- Added optional parameter
  }) {
    return transfersList
        .where((t) {
          bool matchesShop = isReceived
              ? t.toShop == shopCode.value
              : t.fromShop == shopCode.value;

          // Filter by the specific other shop if provided
          bool matchesOther =
              otherShop == null ||
              (isReceived ? t.fromShop == otherShop : t.toShop == otherShop);

          return matchesShop && matchesOther && t.itemType == itemType;
        })
        .fold(0.0, (sum, t) {
          if (field == 'Qty') return sum + t.qty;
          if (field == 'Wt1') return sum + t.weight1;
          if (field == 'Wt2') return sum + t.weight2;
          return sum;
        });
  }

  // Inside ReportsController
  var salesPiecesData = <String, Map<String, double>>{}
      .obs; // Key: Date, Value: Map of Category -> Selling Unit
  final listCategories = [
    'Broiler Small',
    'Broiler Big',
    'DP',
    'OG',
    'Egg',
    'Pota Kalegi',
  ];

  Future<void> calculateSalesPieces() async {
    salesPiecesData.clear();
    DateTime start = _startDate;
    DateTime end = _endDate;

    for (
      DateTime d = start;
      d.isBefore(end);
      d = d.add(const Duration(days: 1))
    ) {
      String dateStr = d.toIso8601String().split('T')[0];
      salesPiecesData[dateStr] = {};

      for (String cat in listCategories) {
        bool isWt1 =
            (cat == 'Broiler Small' ||
            cat == 'DP' ||
            cat == 'Egg' ||
            cat == 'Pota Kalegi');
        String type = 'Unknown';
        if (cat.contains('Broiler')) type = 'Broiler';
        if (cat == 'DP' || cat == 'OG') type = 'Desi';
        if (cat == 'Egg') type = 'Eggs';
        if (cat == 'Pota Kalegi') type = 'Pota Kalegi';

        // 1. Opening Stock (Yesterday's Closing)
        String yestStr = d
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0];
        var openStock = await _stockRepo.getStock(
          shopCode.value,
          yestStr,
          type,
          isWt2: !isWt1,
        );
        double openQty = openStock?.qty ?? 0.0;

        // 2. Closing Stock (Today's Closing)
        var closeStock = await _stockRepo.getStock(
          shopCode.value,
          dateStr,
          type,
          isWt2: !isWt1,
        );
        double closeQty = closeStock?.qty ?? 0.0;

        // 3. Purchase Qty
        double purQty = 0;
        for (var p in purchasesList.where(
          (p) => p.date.startsWith(dateStr) && p.itemType == type,
        )) {
          // Ensure it belongs to the correct category split
          if (type == 'Broiler' || type == 'Desi') {
            if (isWt1 && (p.weight1 ?? 0) > 0) purQty += p.quantity;
            if (!isWt1 && (p.weight2 ?? 0) > 0) purQty += p.quantity;
          } else {
            purQty += p.quantity;
          }
        }

        // 4. Transfers In/Out
        double recQty = 0;
        double sentQty = 0;
        var dayTransfers = transfersList.where(
          (t) => t.date.startsWith(dateStr) && t.itemType == type,
        );

        for (var t in dayTransfers) {
          bool matchesCat = (type == 'Broiler' || type == 'Desi')
              ? (isWt1 ? t.weight1 > 0 : t.weight2 > 0)
              : true;

          if (matchesCat) {
            if (t.toShop == shopCode.value) recQty += t.qty;
            if (t.fromShop == shopCode.value) sentQty += t.qty;
          }
        }

        // 5. Calculate Equation
        double sellingUnit = openQty + purQty + recQty - sentQty - closeQty;
        salesPiecesData[dateStr]![cat] = sellingUnit;
      }
    }
  }

  void editStockMovement(String dateStr) {
    DateTime targetDate = DateTime.parse(dateStr);

    // Navigate to the Stock Movement screen, passing both shopCode and the specific date
    Get.toNamed(
      '/stock-movement', // Ensure this matches your route name in app_routes.dart
      arguments: {'shopCode': shopCode.value, 'date': targetDate},
    )?.then((_) {
      // Refresh the data when the user comes back!
      fetchData();
    });
  }
}
