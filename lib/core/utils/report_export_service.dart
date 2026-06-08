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
    summarySheet.appendRow([TextCellValue('')]); // Blank Row

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
    summarySheet.appendRow([TextCellValue("BIRD'S EYE VIEW (kg)")]);
    summarySheet.appendRow([
      TextCellValue('Item'),
      TextCellValue('Purchase'),
      TextCellValue('Sales'),
      TextCellValue('Difference'),
    ]);
    birdsEyeView.forEach((item, data) {
      summarySheet.appendRow([
        TextCellValue(item),
        DoubleCellValue(data['Purchase'] ?? 0.0),
        DoubleCellValue(data['Sales'] ?? 0.0),
        DoubleCellValue(data['Difference'] ?? 0.0),
      ]);
    });

    // --- SHEET 2: PURCHASES ---
    Sheet purSheet = excel['Purchases'];
    purSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Item Type'),
      TextCellValue('Qty'),
      TextCellValue('Small/DP Wt'),
      TextCellValue('Big/OG Wt'),
      TextCellValue('Rate'),
      TextCellValue('Amount'),
    ]);
    for (var p in purchases) {
      purSheet.appendRow([
        TextCellValue(p.date.split('T')[0]),
        TextCellValue(p.itemType),
        DoubleCellValue(p.quantity.toDouble()),
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
      TextCellValue('Broiler Wt'),
      TextCellValue('Mutton Wt'),
      TextCellValue('DP Wt'),
      TextCellValue('OG Wt'),
      TextCellValue('Eggs'),
      TextCellValue('Pota'),
      TextCellValue('Collected Amount'),
    ]);
    for (var s in sales) {
      salesSheet.appendRow([
        TextCellValue(s.date.split('T')[0]),
        DoubleCellValue(s.broilerWt),
        DoubleCellValue(s.muttonWt),
        DoubleCellValue(s.dpWt),
        DoubleCellValue(s.ogWt),
        IntCellValue(s.eggQty),
        DoubleCellValue(s.potaKalejiWt),
        DoubleCellValue(s.totalAmount),
      ]);
    }

    // --- SHEET 4: EXPENSES ---
    Sheet expSheet = excel['Expenses'];
    expSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Category'),
      TextCellValue('Notes'),
      TextCellValue('Amount'),
    ]);
    for (var e in expenses) {
      expSheet.appendRow([
        TextCellValue(e.date.split('T')[0]),
        TextCellValue(e.category),
        TextCellValue(e.notes),
        DoubleCellValue(e.amount),
      ]);
    }

    // Remove the default empty sheet created by package if it exists
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // --- FILE SAVING LOGIC ---
    // Target the public Downloads directory on Android
    Directory dir = Directory('/storage/emulated/0/Downloads/accounting');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    String startStr = DateFormat('ddMMMyyyy').format(startDate);
    String endStr = DateFormat('ddMMMyyyy').format(endDate);
    String fileName = 'Accounting_${shopCode}_${startStr}_to_$endStr.xlsx';

    File file = File('${dir.path}/$fileName');

    // Write and save the file
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
    }

    MediaScanner.loadMedia(path: file.path);

    return file.path;
  }
}
