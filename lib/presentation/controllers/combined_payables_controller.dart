import 'package:accounting/core/utils/backup_manager.dart';
import 'package:accounting/core/utils/date_util.dart';
import 'package:accounting/core/cache/app_cache.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class PayableSummary {
  final String displayName;
  final int? traderId;
  final String itemType;

  double periodPurchases = 0;
  double periodPayments = 0;
  double lifetimePurchases = 0;
  double lifetimePayments = 0;

  double get outstanding => lifetimePurchases - lifetimePayments;
  double get periodOutstanding => periodPurchases - periodPayments;

  PayableSummary({
    required this.displayName,
    this.traderId,
    required this.itemType,
  });
}

class CombinedPayablesController extends GetxController {
  final PurchaseRepository _purchaseRepo = Get.find<PurchaseRepository>();
  final TraderPaymentRepository _paymentRepo = Get.find<TraderPaymentRepository>();

  var isLoading = false.obs;
  var selectedDate = DateTime.now().obs;
  var traderMap = <int, String>{};

  var allPayments = <TraderPaymentModel>[].obs;
  var payableSummaries = <PayableSummary>[].obs;
  var allPurchases = <PurchaseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    ever(selectedDate, (_) => fetchData());
  }

  DateTime get _startDate => selectedDate.value
      .subtract(Duration(days: selectedDate.value.weekday - 1))
      .copyWith(hour: 0, minute: 0, second: 0);
  DateTime get _endDate => _startDate.add(
    const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
  );
  String get dateDisplay =>
      "${DateUtil.format(_startDate)} to ${DateUtil.format(_endDate)}";

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
      traderMap = await AppCache.instance.getTraderNameMap();

      // Only fetch purchases for the selected week (scoped query)
      String startIso = _startDate.toIso8601String();
      String endIso = _endDate.toIso8601String();

      // Fetch purchases across all shops for the selected week
      List<PurchaseModel> weekPurchases = [];
      for (String shop in ['NK', 'NP', 'PT']) {
        final shopPurchases = await _purchaseRepo.getPurchasesByDateRange(
          shop,
          startIso,
          endIso,
        );
        weekPurchases.addAll(shopPurchases);
      }
      allPurchases.value = weekPurchases;

      // Fetch payments for the following week only
      DateTime nextWeekStart = _startDate.add(const Duration(days: 7));
      DateTime nextWeekEnd = _endDate.add(const Duration(days: 7));
      String nextStartIso = nextWeekStart.toIso8601String();
      String nextEndIso = nextWeekEnd.toIso8601String();

      allPayments.value = await _paymentRepo.getPaymentsByDateRange(
        nextStartIso,
        nextEndIso,
      );

      Map<String, PayableSummary> summaryMap = {};
      String genKey(int? tId, String iType) =>
          tId != null ? 'T_$tId' : 'I_$iType';

      // 1. Process Purchases (For Selected Week)
      for (var p in weekPurchases) {
        String key = genKey(p.traderId, p.itemType);
        if (!summaryMap.containsKey(key)) {
          String name = p.traderId != null && traderMap.containsKey(p.traderId)
              ? traderMap[p.traderId]!
              : p.itemType;
          summaryMap[key] = PayableSummary(
            displayName: name,
            traderId: p.traderId,
            itemType: p.itemType,
          );
        }

        summaryMap[key]!.lifetimePurchases += p.amount;
        summaryMap[key]!.periodPurchases += p.amount;
      }

      // 2. Process Payments (For Following Week)
      for (var pay in allPayments) {
        String key = genKey(pay.traderId, pay.itemType);
        if (summaryMap.containsKey(key)) {
          summaryMap[key]!.lifetimePayments += pay.amount;
          summaryMap[key]!.periodPayments += pay.amount;
        }
      }

      payableSummaries.value = summaryMap.values.toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> savePayment(
    PayableSummary summary,
    double amount,
    String dateStr,
    String notes,
  ) async {
    final payment = TraderPaymentModel(
      traderId: summary.traderId,
      itemType: summary.itemType,
      date: dateStr,
      amount: amount,
      notes: notes,
    );
    try {
      await _paymentRepo.addPayment(payment);
      BackupManager.instance.scheduleBackup();
      fetchData();
      Get.snackbar(
        'Success',
        'Payment saved successfully!',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save payment: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      await _paymentRepo.deletePayment(id);
      BackupManager.instance.scheduleBackup();
      fetchData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete payment: $e',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
