import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = "shop_accounting.db";
  static const int _databaseVersion = 2;

  // Table Names
  static const String tableTraders = 'traders';
  static const String tableRates = 'item_rates';
  static const String tablePurchases = 'purchases';
  static const String tableSales = 'sales';
  static const String tableStock = 'stock';
  static const String tableExpenses = 'expenses';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1. Create Traders Table
    await db.execute('''
      CREATE TABLE $tableTraders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // 2. Create Rates Table
    await db.execute('''
      CREATE TABLE $tableRates (
        item_name TEXT PRIMARY KEY,
        rate REAL NOT NULL
      )
    ''');

    // 3. Create Purchases Table
    await db.execute('''
      CREATE TABLE $tablePurchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_code TEXT NOT NULL,
        item_type TEXT NOT NULL,
        date TEXT NOT NULL,
        quantity REAL NOT NULL, -- Changed from INTEGER to REAL
        weight_1 REAL,
        weight_2 REAL,
        rate REAL NOT NULL,
        amount REAL NOT NULL,
        trader_id INTEGER,
        FOREIGN KEY (trader_id) REFERENCES $tableTraders (id)
      )
    ''');

    // 4. Create Sales Table (including Mutton fields)
    await db.execute('''
      CREATE TABLE $tableSales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_code TEXT NOT NULL,
        date TEXT NOT NULL,
        broiler_wt REAL NOT NULL,
        mutton_opening_wt REAL DEFAULT 0.0,
        mutton_closing_wt REAL DEFAULT 0.0,
        mutton_wt REAL NOT NULL,
        dp_wt REAL NOT NULL,
        og_wt REAL NOT NULL,
        egg_qty INTEGER NOT NULL,
        pota_kaleji_wt REAL NOT NULL,
        selling_amount REAL NOT NULL,
        total_amount REAL NOT NULL,
        difference REAL NOT NULL
      )
    ''');

    // 5. Create Stock Table
    await db.execute('''
      CREATE TABLE $tableStock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_code TEXT NOT NULL,
        date TEXT NOT NULL,
        item_type TEXT NOT NULL,
       qty REAL NOT NULL, -- Changed from INTEGER to REAL
        weight_1 REAL NOT NULL,
        weight_2 REAL NOT NULL
      )
    ''');

    // 6. Create Expenses Table
    await db.execute('''
      CREATE TABLE $tableExpenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_code TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        notes TEXT
      )
    ''');

    // --- SEED INITIAL DATA ---
    final batch = db.batch();
    batch.insert(tableTraders, {'name': 'Golden', 'category': 'Broiler'});
    batch.insert(tableTraders, {'name': 'Naim', 'category': 'Broiler'});
    batch.insert(tableTraders, {'name': 'Diamond', 'category': 'Broiler'});
    batch.insert(tableTraders, {'name': 'Arif', 'category': 'Desi'});
    batch.insert(tableTraders, {'name': 'Ansar', 'category': 'Desi'});

    batch.insert(tableRates, {'item_name': 'Broiler', 'rate': 180.0});
    batch.insert(tableRates, {'item_name': 'Mutton', 'rate': 280.0});
    batch.insert(tableRates, {'item_name': 'DP', 'rate': 260.0});
    batch.insert(tableRates, {'item_name': 'OG', 'rate': 530.0});
    batch.insert(tableRates, {'item_name': 'Eggs', 'rate': 80.0});
    batch.insert(tableRates, {'item_name': 'Pota Kalegi', 'rate': 200.0});

    await batch.commit();
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Turn off foreign keys temporarily for safe table replacement
      await db.execute('PRAGMA foreign_keys=off;');

      // Migrate Purchases Table
      await db.execute('''
        CREATE TABLE purchases_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT, shop_code TEXT NOT NULL, item_type TEXT NOT NULL,
          date TEXT NOT NULL, quantity REAL NOT NULL, weight_1 REAL, weight_2 REAL,
          rate REAL NOT NULL, amount REAL NOT NULL, trader_id INTEGER,
          FOREIGN KEY (trader_id) REFERENCES $tableTraders (id)
        )
      ''');
      await db.execute(
        'INSERT INTO purchases_new SELECT * FROM $tablePurchases',
      );
      await db.execute('DROP TABLE $tablePurchases');
      await db.execute('ALTER TABLE purchases_new RENAME TO $tablePurchases');

      // Migrate Stock Table
      await db.execute('''
        CREATE TABLE stock_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT, shop_code TEXT NOT NULL, date TEXT NOT NULL,
          item_type TEXT NOT NULL, qty REAL NOT NULL, weight_1 REAL NOT NULL, weight_2 REAL NOT NULL
        )
      ''');
      await db.execute('INSERT INTO stock_new SELECT * FROM $tableStock');
      await db.execute('DROP TABLE $tableStock');
      await db.execute('ALTER TABLE stock_new RENAME TO $tableStock');

      await db.execute('PRAGMA foreign_keys=on;');
    }
  }
}
