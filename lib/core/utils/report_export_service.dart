// lib/core/utils/report_export_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../data/models/app_models.dart';
import 'package:media_scanner/media_scanner.dart';

class ReportExportService {
  static Future<String> exportReport({
    required String shopCode,
    required DateTime startDate,
    required DateTime endDate,
    required List<PurchaseModel> purchases,
    required List<SaleModel> sales,
    required List<ExpenseModel> expenses,
    required Map<String, double> traderPayables,
    required Map<String, Map<String, double>> birdsEyeView,
    required double totalCollected,
    required double totalPurchases,
    required double totalExpenses,
    required double netPosition,
    // --- NEW: Added salesPiecesData parameter ---
    required Map<String, Map<String, double>> salesPiecesData,
  }) async {
    var excel = Excel.createExcel();

    // --- SHEET 1: SUMMARY ---
    Sheet summarySheet = excel['Summary'];
    excel.setDefaultSheet('Summary');

    // Period Analysis
    summarySheet.appendRow([TextCellValue('PERIOD ANALYSIS')]);
    summarySheet.appendRow([
      TextCellValue('Total Collected Sales'),
      DoubleCellValue(totalCollected),
    ]);
    summarySheet.appendRow([
      TextCellValue('Total Purchases'),
      DoubleCellValue(totalPurchases),
    ]);
    summarySheet.appendRow([
      TextCellValue('Weekly Expenses'),
      DoubleCellValue(totalExpenses),
    ]);
    summarySheet.appendRow([
      TextCellValue('Net Cash Position'),
      DoubleCellValue(netPosition),
    ]);

    summarySheet.appendRow([TextCellValue('')]); // Blank row

    // Trader Payables
    summarySheet.appendRow([TextCellValue('AMOUNT PAYABLE TO TRADERS')]);
    double grandTotalTraders = 0;
    traderPayables.forEach((trader, amount) {
      summarySheet.appendRow([TextCellValue(trader), DoubleCellValue(amount)]);
      grandTotalTraders += amount;
    });
    summarySheet.appendRow([
      TextCellValue('GRAND TOTAL'),
      DoubleCellValue(grandTotalTraders),
    ]);
    summarySheet.appendRow([TextCellValue('')]); // Blank Row

    // Bird's Eye View
    summarySheet.appendRow([TextCellValue('BIRDS EYE VIEW (kg)')]);
    summarySheet.appendRow([
      TextCellValue('Item'),
      TextCellValue('Purchase'),
      TextCellValue('Sales'),
      TextCellValue('Dead'),
      TextCellValue('Difference'),
    ]);
    birdsEyeView.forEach((item, data) {
      summarySheet.appendRow([
        TextCellValue(item),
        DoubleCellValue(data['Purchase']!),
        DoubleCellValue(data['Sales']!),
        DoubleCellValue(data['Dead']!),
        DoubleCellValue(data['Difference']!),
      ]);
    });

    // --- SHEET 2: PURCHASES ---
    Sheet purSheet = excel['Purchases'];
    purSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Type'),
      TextCellValue('Qty'),
      TextCellValue('Wt1'),
      TextCellValue('Wt2'),
      TextCellValue('Rate'),
      TextCellValue('Amount'),
    ]);
    for (var p in purchases) {
      purSheet.appendRow([
        TextCellValue(p.date.split('T')[0]),
        TextCellValue(p.itemType),
        DoubleCellValue(p.quantity),
        DoubleCellValue(p.weight1 ?? 0.0),
        DoubleCellValue(p.weight2 ?? 0.0),
        DoubleCellValue(p.rate),
        DoubleCellValue(p.amount),
      ]);
    }

    // --- SHEET 3: SALES ---
    Sheet salesSheet = excel['Sales'];
    salesSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Broiler (Qty/Wt/Dead/DWt)'),
      TextCellValue('Mutton (Qty/Wt)'),
      TextCellValue('DP (Qty/Wt/Dead/DWt)'),
      TextCellValue('OG (Qty/Wt/Dead/DWt)'),
      TextCellValue('Egg Qty'),
      TextCellValue('Pota (Qty/Wt)'),
      TextCellValue('System Amt'),
      TextCellValue('Collected Amt'),
      TextCellValue('Diff'),
    ]);
    for (var s in sales) {
      salesSheet.appendRow([
        TextCellValue(s.date.split('T')[0]),
        TextCellValue(
          '${s.broilerQty} / ${s.broilerWt} / ${s.broilerDeadQty} / ${s.broilerDeadWt}',
        ),
        TextCellValue('${s.muttonQty} / ${s.muttonWt}'),
        TextCellValue(
          '${s.dpQty} / ${s.dpWt} / ${s.dpDeadQty} / ${s.dpDeadWt}',
        ),
        TextCellValue(
          '${s.ogQty} / ${s.ogWt} / ${s.ogDeadQty} / ${s.ogDeadWt}',
        ),
        IntCellValue(s.eggQty),
        TextCellValue('${s.potaKalejiQty} / ${s.potaKalejiWt}'),
        DoubleCellValue(s.sellingAmount),
        DoubleCellValue(s.totalAmount),
        DoubleCellValue(s.difference),
      ]);
    }

    // --- SHEET 4: EXPENSES ---
    Sheet expSheet = excel['Expenses'];
    expSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Category'),
      TextCellValue('Amount'),
      TextCellValue('Notes'),
    ]);
    for (var e in expenses) {
      expSheet.appendRow([
        TextCellValue(e.date.split('T')[0]),
        TextCellValue(e.category),
        DoubleCellValue(e.amount),
        TextCellValue(e.notes),
      ]);
    }

    // --- SHEET 5: UNITS (NEW!) ---
    Sheet unitsSheet = excel['Units'];
    unitsSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Broiler Small'),
      TextCellValue('Broiler Big'),
      TextCellValue('DP'),
      TextCellValue('OG'),
      TextCellValue('Egg'),
      TextCellValue('Pota Kalegi'),
    ]);

    // Sort dates chronologically before writing
    var sortedDates = salesPiecesData.keys.toList()..sort();

    for (String date in sortedDates) {
      var dataMap = salesPiecesData[date]!;
      unitsSheet.appendRow([
        TextCellValue(date),
        DoubleCellValue(dataMap['Broiler Small'] ?? 0.0),
        DoubleCellValue(dataMap['Broiler Big'] ?? 0.0),
        DoubleCellValue(dataMap['DP'] ?? 0.0),
        DoubleCellValue(dataMap['OG'] ?? 0.0),
        DoubleCellValue(dataMap['Egg'] ?? 0.0),
        DoubleCellValue(dataMap['Pota Kalegi'] ?? 0.0),
      ]);
    }

    // Remove the default empty sheet created by package if it exists
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // --- FILE SAVING LOGIC ---
    Directory dir = Directory('/storage/emulated/0/Downloads/accounting');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    String startStr = DateFormat('ddMMMyyyy').format(startDate);
    String endStr = DateFormat('ddMMMyyyy').format(endDate);
    String fileName = 'Accounting_${shopCode}_${startStr}_to_$endStr.xlsx';

    File file = File('${dir.path}/$fileName');

    var fileBytes = excel.save();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
      await MediaScanner.loadMedia(path: file.path);
    }

    return file.path;
  }
}
