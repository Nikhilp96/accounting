// lib/presentation/controllers/stock_movement_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

class MovementData {
  var openQty = 0.0.obs;
  var closeQty = 0.0.obs;

  // Weights (Only used for birds, ignored for Eggs/Pota)
  var openWt = 0.0.obs;
  var closeWt = 0.0.obs;

  // Shop 1 (e.g. NP)
  var sendS1Qty = 0.0.obs;
  var sendS1Wt = 0.0.obs;
  var recvS1Qty = 0.0.obs;
  var recvS1Wt = 0.0.obs;

  // Shop 2 (e.g. PT)
  var sendS2Qty = 0.0.obs;
  var sendS2Wt = 0.0.obs;
  var recvS2Qty = 0.0.obs;
  var recvS2Wt = 0.0.obs;
}

class StockMovementController extends GetxController {
  final StockRepository _stockRepo = Get.find();
  final TransferRepository _transferRepo = Get.find();

  late String shopCode;
  late List<String> otherShops;

  var date = DateTime.now().obs;
  var isLoading = false.obs;

  // Categories
  final categories = [
    'Broiler Small',
    'Broiler Big',
    'DP',
    'OG',
    'Egg',
    'Pota Kalegi',
  ];

  var movementMap = <String, MovementData>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // UPDATED: Handle Map arguments to allow loading specific dates
    final args = Get.arguments;
    if (args is Map) {
      shopCode = args['shopCode'];
      if (args['date'] != null) {
        date.value = args['date'];
      }
    } else {
      shopCode = args as String;
    }

    otherShops = ['NK', 'NP', 'PT'].where((s) => s != shopCode).toList();

    for (var cat in categories) {
      movementMap[cat] = MovementData();
    }
    loadDailyData();
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      date.value = picked;
      loadDailyData();
    }
  }

  Future<void> loadDailyData() async {
    isLoading.value = true;
    String today = date.value.toIso8601String().split('T')[0];
    String yesterday = date.value
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    // Reset current form
    for (var cat in categories) {
      movementMap[cat] = MovementData();
    }

    // 1. Fetch Yesterday's Closing Stock (to auto-fill today's opening)
    for (var cat in categories) {
      var dbInfo = _getDbMapping(cat);
      var yestStock = await _stockRepo.getStock(
        shopCode,
        yesterday,
        dbInfo['type'],
        isWt2: !dbInfo['isWt1'],
      );
      if (yestStock != null) {
        movementMap[cat]!.openQty.value = yestStock.qty;
        movementMap[cat]!.openWt.value = dbInfo['isWt1']
            ? yestStock.weight1
            : yestStock.weight2;
      }

      // Override with Today's Opening/Closing if it exists
      var todayStock = await _stockRepo.getStock(
        shopCode,
        today,
        dbInfo['type'],
        isWt2: !dbInfo['isWt1'],
      );
      if (todayStock != null) {
        // If a record exists for today, we map it to closing stock
        movementMap[cat]!.closeQty.value = todayStock.qty;
        movementMap[cat]!.closeWt.value = dbInfo['isWt1']
            ? todayStock.weight1
            : todayStock.weight2;
      }
    }

    // 2. Fetch Today's Transfers
    var transfers = await _transferRepo.getTransfersForShop(
      shopCode,
      today,
      today,
    );
    for (var t in transfers) {
      String cat = _getCategoryFromTransfer(t);
      if (cat.isEmpty) continue;

      double wt = _getDbMapping(cat)['isWt1'] ? t.weight1 : t.weight2;

      if (t.fromShop == shopCode) {
        // Sent
        if (t.toShop == otherShops[0]) {
          movementMap[cat]!.sendS1Qty.value += t.qty;
          movementMap[cat]!.sendS1Wt.value += wt;
        } else if (otherShops.length > 1 && t.toShop == otherShops[1]) {
          movementMap[cat]!.sendS2Qty.value += t.qty;
          movementMap[cat]!.sendS2Wt.value += wt;
        }
      } else if (t.toShop == shopCode) {
        // Received
        if (t.fromShop == otherShops[0]) {
          movementMap[cat]!.recvS1Qty.value += t.qty;
          movementMap[cat]!.recvS1Wt.value += wt;
        } else if (otherShops.length > 1 && t.fromShop == otherShops[1]) {
          movementMap[cat]!.recvS2Qty.value += t.qty;
          movementMap[cat]!.recvS2Wt.value += wt;
        }
      }
    }
    isLoading.value = false;
  }

  Future<void> saveMovementLog() async {
    isLoading.value = true;
    String todayStr = date.value.toIso8601String().split('T')[0];

    try {
      // ---> NEW: Clear existing transfers for this shop and date to prevent duplicate summing
      await _transferRepo.deleteTransfersByDateAndShop(todayStr, shopCode);

      for (var cat in categories) {
        var data = movementMap[cat]!;
        var dbInfo = _getDbMapping(cat);
        String type = dbInfo['type'];
        bool isWt1 = dbInfo['isWt1'];

        // Save Closing Stock
        StockModel closing = StockModel(
          shopCode: shopCode,
          date: todayStr,
          itemType: type,
          qty: data.closeQty.value,
          weight1: isWt1 ? data.closeWt.value : 0.0,
          weight2: !isWt1 ? data.closeWt.value : 0.0,
        );
        await _stockRepo.saveStock(closing);

        // Helper to save transfer
        Future<void> _saveT(String to, String from, double q, double w) async {
          if (q == 0 && w == 0) return;
          await _transferRepo.addTransfer(
            TransferModel(
              date: todayStr,
              fromShop: from,
              toShop: to,
              itemType: type,
              qty: q,
              weight1: isWt1 ? w : 0.0,
              weight2: !isWt1 ? w : 0.0,
            ),
          );
        }

        // Save Sends (ShopCode -> OtherShop)
        await _saveT(
          otherShops[0],
          shopCode,
          data.sendS1Qty.value,
          data.sendS1Wt.value,
        );
        if (otherShops.length > 1) {
          await _saveT(
            otherShops[1],
            shopCode,
            data.sendS2Qty.value,
            data.sendS2Wt.value,
          );
        }

        // Save Receives (OtherShop -> ShopCode)
        await _saveT(
          shopCode,
          otherShops[0],
          data.recvS1Qty.value,
          data.recvS1Wt.value,
        );
        if (otherShops.length > 1) {
          await _saveT(
            shopCode,
            otherShops[1],
            data.recvS2Qty.value,
            data.recvS2Wt.value,
          );
        }
      }

      isLoading.value = false;
      Get.back();
      Get.snackbar(
        'Success',
        'Stock Movement logged successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to save stock movement: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Map<String, dynamic> _getDbMapping(String category) {
    switch (category) {
      case 'Broiler Small':
        return {'type': 'Broiler', 'isWt1': true};
      case 'Broiler Big':
        return {'type': 'Broiler', 'isWt1': false};
      case 'DP':
        return {'type': 'Desi', 'isWt1': true};
      case 'OG':
        return {'type': 'Desi', 'isWt1': false};
      case 'Egg':
        return {'type': 'Eggs', 'isWt1': true};
      case 'Pota Kalegi':
        return {'type': 'Pota Kalegi', 'isWt1': true};
      default:
        return {'type': 'Unknown', 'isWt1': true};
    }
  }

  String _getCategoryFromTransfer(TransferModel t) {
    if (t.itemType == 'Broiler') {
      return t.weight2 > 0 ? 'Broiler Big' : 'Broiler Small';
    }
    if (t.itemType == 'Desi') return t.weight2 > 0 ? 'OG' : 'DP';
    if (t.itemType == 'Eggs') return 'Egg';
    if (t.itemType == 'Pota Kalegi') return 'Pota Kalegi';
    return '';
  }
}
