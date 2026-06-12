import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:media_scanner/media_scanner.dart';
import '../database/db_helper.dart';

class BackupService {
  static const String _folderPath = '/storage/emulated/0/Downloads/accounting';
  static const String _fileName = 'shop_backup.xlsx';

  // --- 1. PERMISSIONS ---
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
      var status = await Permission.storage.request();
      return status.isGranted;
    }
    return false;
  }

  // --- 2. EXPORT TO EXCEL (BACKUP) ---
  static Future<String?> exportToExcel() async {
    if (!await requestPermissions()) return null;

    final db = await DatabaseHelper.instance.database;
    var excel = Excel.createExcel();

    // Export each table to a separate sheet
    await _exportTableToSheet(db, excel, DatabaseHelper.tableTraders);
    await _exportTableToSheet(db, excel, DatabaseHelper.tableRates);
    await _exportTableToSheet(db, excel, DatabaseHelper.tablePurchases);
    await _exportTableToSheet(db, excel, DatabaseHelper.tableSales);
    await _exportTableToSheet(db, excel, DatabaseHelper.tableStock);
    await _exportTableToSheet(db, excel, DatabaseHelper.tableExpenses);
    await _exportTableToSheet(db, excel, DatabaseHelper.tableTraderPayments);

    // Remove the default 'Sheet1'
    if (excel.tables.keys.contains('Sheet1') && excel.tables.keys.length > 1) {
      excel.delete('Sheet1');
    }

    // Save File
    final dir = Directory(_folderPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File('$_folderPath/$_fileName');
    await file.writeAsBytes(excel.save()!);
    debugPrint('Backup updated at: $_folderPath/$_fileName');

    MediaScanner.loadMedia(path: file.path);

    return file.path; 
  }

  static Future<void> _exportTableToSheet(
    Database db,
    Excel excel,
    String tableName,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    Sheet sheet = excel[tableName];

    if (maps.isEmpty) return;

    // Write Headers
    List<String> headers = maps.first.keys.toList();
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // Write Data
    for (var row in maps) {
      List<CellValue> rowValues = [];
      for (var key in headers) {
        var value = row[key];
        if (value == null) {
          rowValues.add(TextCellValue(''));
        } else if (value is int) {
          rowValues.add(IntCellValue(value));
        } else if (value is double) {
          rowValues.add(DoubleCellValue(value));
        } else {
          rowValues.add(TextCellValue(value.toString()));
        }
      }
      sheet.appendRow(rowValues);
    }
  }

  // --- 3. RESTORE FROM EXCEL ---
  static Future<bool> restoreFromExcel() async {
    if (!await requestPermissions()) return false;

    final file = File('$_folderPath/$_fileName');
    if (!await file.exists()) return false;

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    final db = await DatabaseHelper.instance.database;

    try {
      await db.transaction((txn) async {
        await _importSheetToTable(txn, excel, DatabaseHelper.tableTraders);
        await _importSheetToTable(txn, excel, DatabaseHelper.tableRates);
        await _importSheetToTable(txn, excel, DatabaseHelper.tablePurchases);
        await _importSheetToTable(txn, excel, DatabaseHelper.tableSales);
        await _importSheetToTable(txn, excel, DatabaseHelper.tableStock);

        // --- NEW TABLES ADDED HERE ---
        await _importSheetToTable(txn, excel, DatabaseHelper.tableExpenses);
        await _importSheetToTable(
          txn,
          excel,
          DatabaseHelper.tableTraderPayments,
        );
      });
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  static Future<void> _importSheetToTable(
    Transaction txn,
    Excel excel,
    String tableName,
  ) async {
    if (!excel.tables.keys.contains(tableName)) return;

    Sheet sheet = excel.tables[tableName]!;
    if (sheet.maxRows < 2) return; // No data, just headers or empty

    // Clear existing table data to prevent duplicate primary keys
    await txn.delete(tableName);

    List<Data?> headersRow = sheet.rows[0];
    List<String> headers = headersRow
        .map((e) => e?.value.toString() ?? '')
        .toList();

    for (int i = 1; i < sheet.maxRows; i++) {
      List<Data?> row = sheet.rows[i];
      Map<String, dynamic> rowData = {};

      for (int j = 0; j < headers.length; j++) {
        if (j < row.length && row[j] != null) {
          var val = row[j]!.value;
          // Clean up dynamic Excel types
          if (val is IntCellValue) {
            rowData[headers[j]] = val.value;
          } else if (val is DoubleCellValue) {
            rowData[headers[j]] = val.value;
          } else if (val is TextCellValue) {
            rowData[headers[j]] = val.value.toString();
          } else {
            rowData[headers[j]] = val.toString();
          }
        } else {
          rowData[headers[j]] = null;
        }
      }

      // Do not re-insert the auto-increment ID if it is null or empty
      if (rowData['id'] == '' || rowData['id'] == 'null') {
        rowData.remove('id');
      }

      await txn.insert(tableName, rowData);
    }
  }
}
