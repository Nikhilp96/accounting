import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/repositories.dart';
import '../../data/models/app_models.dart'; // Added for RateModel

class ShopPerformanceData {
  final String shopCode;
  double systemSales = 0.0;
  double totalCollected = 0.0;
  double totalPurchases = 0.0;
  double totalExpenses = 0.0;

  // Formulas
  double get netProfit => totalCollected - totalPurchases - totalExpenses;
  double get leakage => totalCollected - systemSales;

  ShopPerformanceData(this.shopCode);
}

// --- NEW: Profitability Data Structure ---
class ItemMarginData {
  final String itemName;
  double totalPurchaseCost = 0.0;
  double totalUnitsPurchased = 0.0;
  double sellingRate = 0.0;

  double get avgPurchaseRate =>
      totalUnitsPurchased > 0 ? totalPurchaseCost / totalUnitsPurchased : 0.0;
  double get grossMargin => sellingRate - avgPurchaseRate;
  double get marginPercent =>
      avgPurchaseRate > 0 ? (grossMargin / avgPurchaseRate) * 100 : 0.0;

  ItemMarginData(this.itemName);
}

class AnalyticsController extends GetxController {
  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  final SalesRepository _salesRepo = SalesRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final RateRepository _rateRepo =
      RateRepository(); // <-- Added to fetch Selling Rates

  var isLoading = false.obs;
  var selectedDate = DateTime.now().obs;

  // Analytical reactive containers
  var shopPerformances = <String, ShopPerformanceData>{}.obs;
  var categoryExpenses = <String, double>{}.obs;
  var itemMargins = <ItemMarginData>[].obs; // <-- Added Margin Container

  // Master Aggregates
  var grandTotalCollected = 0.0.obs;
  var grandTotalPurchases = 0.0.obs;
  var grandTotalExpenses = 0.0.obs;
  var masterNetProfit = 0.0.obs;
  var masterLeakage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    calculateAnalytics();
    ever(selectedDate, (_) => calculateAnalytics());
  }

  DateTime get _startDate => selectedDate.value
      .subtract(Duration(days: selectedDate.value.weekday - 1))
      .copyWith(hour: 0, minute: 0, second: 0);
  DateTime get _endDate => _startDate.add(
    const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
  );

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> calculateAnalytics() async {
    isLoading.value = true;
    try {
      String startIso = _startDate.toIso8601String();
      String endIso = _endDate.toIso8601String();

      // 1. Fetch Master Selling Rates
      final rates = await _rateRepo.getAllRates();
      Map<String, double> sellingRates = {
        for (var r in rates) r.itemName: r.rate,
      };

      // Initialize structures
      List<String> shops = ['NK', 'NP', 'PT'];
      Map<String, ShopPerformanceData> tempPerformance = {
        for (var s in shops) s: ShopPerformanceData(s),
      };
      Map<String, double> tempExpenses = {};
      Map<String, ItemMarginData> tempMargins = {}; // Temporary margin map

      double gCollected = 0.0,
          gPurchases = 0.0,
          gExpenses = 0.0,
          gLeakage = 0.0;

      for (String shop in shops) {
        final purchases = await _purchaseRepo.getPurchasesByDateRange(
          shop,
          startIso,
          endIso,
        );
        final sales = await _salesRepo.getSalesByDateRange(
          shop,
          startIso,
          endIso,
        );
        final expenses = await _expenseRepo.getExpensesByRange(
          shop,
          startIso,
          endIso,
        );

        // Purchases & Item Margin Calculations
        double pTotal = 0.0;
        for (var p in purchases) {
          pTotal += p.amount;

          // Item-Wise Aggregation
          String key = p.itemType;
          if (!tempMargins.containsKey(key)) {
            tempMargins[key] = ItemMarginData(key);
            // If buying 'Desi', compare against 'DP' selling rate as a baseline proxy if specific Desi rate is missing
            tempMargins[key]!.sellingRate =
                sellingRates[key] ?? sellingRates['DP'] ?? 0.0;
          }

          tempMargins[key]!.totalPurchaseCost += p.amount;
          if (p.rate > 0) {
            // Amount / Rate = Exact units (kg or pieces) billed by the trader
            tempMargins[key]!.totalUnitsPurchased += (p.amount / p.rate);
          }
        }
        tempPerformance[shop]!.totalPurchases = pTotal;
        gPurchases += pTotal;

        // Sales & Leakage
        double sCollected = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
        double sSystem = sales.fold(0.0, (sum, s) => sum + s.sellingAmount);
        tempPerformance[shop]!.totalCollected = sCollected;
        tempPerformance[shop]!.systemSales = sSystem;
        gCollected += sCollected;

        double shopLeakage = sCollected - sSystem;
        gLeakage += shopLeakage;

        // Expenses
        double eTotal = 0.0;
        for (var e in expenses) {
          tempExpenses[e.category] =
              (tempExpenses[e.category] ?? 0.0) + e.amount;
          eTotal += e.amount;
        }
        tempPerformance[shop]!.totalExpenses = eTotal;
        gExpenses += eTotal;
      }

      // Update State
      shopPerformances.value = tempPerformance;
      categoryExpenses.value = tempExpenses;
      itemMargins.value = tempMargins.values.toList(); // Bind margins to UI

      grandTotalCollected.value = gCollected;
      grandTotalPurchases.value = gPurchases;
      grandTotalExpenses.value = gExpenses;
      masterNetProfit.value = gCollected - gPurchases - gExpenses;
      masterLeakage.value = gLeakage;
    } finally {
      isLoading.value = false;
    }
  }
}
