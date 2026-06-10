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

    // --- SHEET 3: SALES (UPDATED WITH QUANTITIES & BALANCES) ---
    Sheet salesSheet = excel['Sales'];
    salesSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Broiler Qty'),
      TextCellValue('Broiler Wt'),
      TextCellValue('Mutton Qty'),
      TextCellValue('Mutton Wt'),
      TextCellValue('Mutton Opening Wt'),
      TextCellValue('Mutton Closing Wt'),
      TextCellValue('DP Qty'),
      TextCellValue('DP Wt'),
      TextCellValue('OG Qty'),
      TextCellValue('OG Wt'),
      TextCellValue('Eggs (Pcs)'),
      TextCellValue('Pota Qty'),
      TextCellValue('Pota Wt'),
      TextCellValue('System Amt (₹)'),
      TextCellValue('Collected Amt (₹)'),
      TextCellValue('Difference (₹)'),
    ]);

    for (var s in sales) {
      salesSheet.appendRow([
        TextCellValue(s.date.split('T')[0]),
        IntCellValue(s.broilerQty),
        DoubleCellValue(s.broilerWt),
        IntCellValue(s.muttonQty),
        DoubleCellValue(s.muttonWt),
        DoubleCellValue(s.muttonOpeningWt),
        DoubleCellValue(s.muttonClosingWt),
        IntCellValue(s.dpQty),
        DoubleCellValue(s.dpWt),
        IntCellValue(s.ogQty),
        DoubleCellValue(s.ogWt),
        IntCellValue(s.eggQty),
        IntCellValue(s.potaKalejiQty),
        DoubleCellValue(s.potaKalejiWt),
        DoubleCellValue(s.sellingAmount),
        DoubleCellValue(s.totalAmount),
        DoubleCellValue(s.difference),
      ]);
    }

    // --- SHEET 4: EXPENSES (REMOVED NOTES COLUMN) ---
    Sheet expSheet = excel['Expenses'];
    expSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Category'),
      TextCellValue('Amount'),
    ]);
    for (var e in expenses) {
      expSheet.appendRow([
        TextCellValue(e.date.split('T')[0]),
        TextCellValue(e.category),
        DoubleCellValue(e.amount),
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

    // Write and save the file
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
    }

    MediaScanner.loadMedia(path: file.path);

    return file.path;
  }
}
