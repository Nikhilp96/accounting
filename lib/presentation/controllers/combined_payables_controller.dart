import 'package:accounting/core/utils/backup_service.dart';
import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class PayableSummary {
  final String displayName;
  final int? traderId;
  final String itemType;

  double periodPurchases = 0;
  double lifetimePurchases = 0;
  double lifetimePayments = 0;
  double get outstanding => lifetimePurchases - lifetimePayments;

  PayableSummary({
    required this.displayName,
    this.traderId,
    required this.itemType,
  });
}

class CombinedPayablesController extends GetxController {
  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  final TraderPaymentRepository _paymentRepo = TraderPaymentRepository();
  final TraderRepository _traderRepo = TraderRepository();

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
      final traders = await _traderRepo.getAllTraders();
      for (var t in traders) {
        if (t.id != null) traderMap[t.id!] = t.name;
      }

      final purchases = await _purchaseRepo.getAllPurchases();
      allPurchases.value = purchases;
      allPayments.value = await _paymentRepo.getAllPayments();

      Map<String, PayableSummary> summaryMap = {};
      String genKey(int? tId, String iType) =>
          tId != null ? 'T_$tId' : 'I_$iType';

      // 1. Process Purchases
      for (var p in purchases) {
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

        DateTime pDate = DateTime.parse(p.date);
        if (pDate.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
            pDate.isBefore(_endDate.add(const Duration(seconds: 1)))) {
          summaryMap[key]!.periodPurchases += p.amount;
        }
      }

      // 2. Process Payments
      for (var pay in allPayments) {
        String key = genKey(pay.traderId, pay.itemType);
        if (summaryMap.containsKey(key)) {
          summaryMap[key]!.lifetimePayments += pay.amount;
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
    await _paymentRepo.addPayment(payment);
    await BackupService.exportToExcel();
    fetchData();
    Get.snackbar(
      'Success',
      'Payment saved successfully!',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  Future<void> deletePayment(int id) async {
    await _paymentRepo.deletePayment(id);
    await BackupService.exportToExcel();
    fetchData();
  }
}
