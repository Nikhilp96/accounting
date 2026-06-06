import 'package:sqflite/sqflite.dart';
import '../../core/database/db_helper.dart';
import '../models/app_models.dart';
import '../../core/utils/backup_service.dart';

class RateRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<RateModel>> getAllRates() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRates,
    );
    return maps
        .map((e) => RateModel(itemName: e['item_name'], rate: e['rate']))
        .toList();
  }

  Future<int> updateRate(String itemName, double newRate) async {
    final db = await dbHelper.database;
    return await db.update(
      DatabaseHelper.tableRates,
      {'rate': newRate},
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
  }
}

class TraderRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<TraderModel>> getTradersByCategory(String category) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableTraders,
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps
        .map(
          (e) => TraderModel(
            id: e['id'] as int,
            name: e['name'] as String,
            category: e['category'] as String,
          ),
        )
        .toList();
  }

  Future<List<TraderModel>> getAllTraders() async {
    final db = await dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableTraders);
    return maps
        .map(
          (e) => TraderModel(
            id: e['id'] as int,
            name: e['name'] as String,
            category: e['category'] as String,
          ),
        )
        .toList();
  }

  Future<int> addTrader(TraderModel trader) async {
    final db = await dbHelper.database;
    return await db.insert(DatabaseHelper.tableTraders, {
      'name': trader.name,
      'category': trader.category,
    });
  }
}

class PurchaseRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> addPurchase(PurchaseModel purchase) async {
    final db = await dbHelper.database;
    int id = await db.insert(DatabaseHelper.tablePurchases, purchase.toMap());

    // Trigger background backup
    BackupService.exportToExcel();

    return id;
  }

  Future<int> updatePurchase(PurchaseModel purchase) async {
    final db = await dbHelper.database;
    int result = await db.update(
      DatabaseHelper.tablePurchases,
      purchase.toMap(),
      where: 'id = ?',
      whereArgs: [purchase.id],
    );
    BackupService.exportToExcel(); // Sync to Excel
    return result;
  }

  Future<int> deletePurchase(int id) async {
    final db = await dbHelper.database;
    int result = await db.delete(
      DatabaseHelper.tablePurchases,
      where: 'id = ?',
      whereArgs: [id],
    );
    BackupService.exportToExcel(); // Sync to Excel
    return result;
  }

  Future<List<PurchaseModel>> getPurchasesByDateRange(
    String shopCode,
    String startDate,
    String endDate,
  ) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tablePurchases,
      where: 'shop_code = ? AND date >= ? AND date <= ?',
      whereArgs: [shopCode, startDate, endDate],
      orderBy: 'date DESC',
    );
    return maps.map((e) => PurchaseModel.fromMap(e)).toList();
  }
}

class SalesRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> addSale(SaleModel sale) async {
    final db = await dbHelper.database;
    int id = await db.insert(DatabaseHelper.tableSales, sale.toMap());

    // Trigger background backup
    BackupService.exportToExcel();

    return id;
  }

  Future<int> updateSale(SaleModel sale) async {
    final db = await dbHelper.database;
    int result = await db.update(
      DatabaseHelper.tableSales,
      sale.toMap(),
      where: 'id = ?',
      whereArgs: [sale.id],
    );
    BackupService.exportToExcel(); // Sync to Excel
    return result;
  }

  Future<int> deleteSale(int id) async {
    final db = await dbHelper.database;
    int result = await db.delete(
      DatabaseHelper.tableSales,
      where: 'id = ?',
      whereArgs: [id],
    );
    BackupService.exportToExcel(); // Sync to Excel
    return result;
  }

  Future<List<SaleModel>> getSalesByDateRange(
    String shopCode,
    String startDate,
    String endDate,
  ) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableSales,
      where: 'shop_code = ? AND date >= ? AND date <= ?',
      whereArgs: [shopCode, startDate, endDate],
      orderBy: 'date DESC',
    );
    return maps.map((e) => SaleModel.fromMap(e)).toList();
  }
}
