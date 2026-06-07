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
    int id = await db.update(
      DatabaseHelper.tableRates,
      {'rate': newRate},
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
    BackupService.exportToExcel();
    return id;
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
    int id = await db.insert(DatabaseHelper.tableTraders, {
      'name': trader.name,
      'category': trader.category,
    });
    BackupService.exportToExcel();
    return id;
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

class StockRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<StockModel?> getStock(
    String shopCode,
    String date,
    String itemType,
  ) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableStock,
      where: 'shop_code = ? AND date = ? AND item_type = ?',
      whereArgs: [shopCode, date, itemType],
    );
    if (maps.isNotEmpty) {
      return StockModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> saveStock(StockModel stock) async {
    final db = await dbHelper.database;
    final existing = await getStock(stock.shopCode, stock.date, stock.itemType);

    if (existing != null) {
      // Create a map without the ID for the update payload
      final updateData = stock.toMap();
      updateData.remove('id');

      await db.update(
        DatabaseHelper.tableStock,
        updateData,
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      // For insertion, we don't include the ID at all,
      // let SQLite handle the AUTOINCREMENT
      final insertData = stock.toMap();
      insertData.remove('id');

      await db.insert(DatabaseHelper.tableStock, insertData);
    }
    BackupService.exportToExcel();
  }
}

class ExpenseRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> addExpense(ExpenseModel expense) async {
    final db = await dbHelper.database;
    int id = await db.insert(DatabaseHelper.tableExpenses, expense.toMap());
    BackupService.exportToExcel();
    return id;
  }

  Future<List<ExpenseModel>> getExpensesByRange(
    String shopCode,
    String start,
    String end,
  ) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableExpenses,
      where: 'shop_code = ? AND date >= ? AND date <= ?',
      whereArgs: [shopCode, start, end],
    );
    return maps.map((e) => ExpenseModel.fromMap(e)).toList();
  }
}
