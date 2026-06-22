import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = "shop_accounting.db";
  static const int _databaseVersion = 7;

  // Table Names
  static const String tableTraders = 'traders';
  static const String tableRates = 'item_rates';
  static const String tablePurchases = 'purchases';
  static const String tableSales = 'sales';
  static const String tableStock = 'stock';
  static const String tableExpenses = 'expenses';
  static const String tableTraderPayments = 'trader_payments';
  static const String tableExpenseCategories = 'expense_categories';
  static const String tableTransfers = 'transfers';

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
        broiler_qty INTEGER NOT NULL DEFAULT 0,
        broiler_wt REAL NOT NULL,
        broiler_dead_qty INTEGER NOT NULL DEFAULT 0,
        broiler_dead_wt REAL NOT NULL DEFAULT 0.0,
        mutton_opening_wt REAL DEFAULT 0.0,
        mutton_closing_wt REAL DEFAULT 0.0,
        mutton_qty INTEGER NOT NULL DEFAULT 0,
        mutton_wt REAL NOT NULL,
        dp_qty INTEGER NOT NULL DEFAULT 0,
        dp_wt REAL NOT NULL,
        dp_dead_qty INTEGER NOT NULL DEFAULT 0,
        dp_dead_wt REAL NOT NULL DEFAULT 0.0,
        og_qty INTEGER NOT NULL DEFAULT 0,
        og_wt REAL NOT NULL,
        og_dead_qty INTEGER NOT NULL DEFAULT 0,
        og_dead_wt REAL NOT NULL DEFAULT 0.0,
        egg_qty INTEGER NOT NULL,
        pota_kaleji_qty INTEGER NOT NULL DEFAULT 0,
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

    await db.execute('''
      CREATE TABLE $tableTraderPayments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trader_id INTEGER,
        item_type TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY (trader_id) REFERENCES $tableTraders (id)
      )
    ''');

    await db.execute('''
    CREATE TABLE $tableExpenseCategories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      is_salary INTEGER NOT NULL DEFAULT 0
    )
  ''');

    await db.execute('''
      CREATE TABLE $tableTransfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        from_shop TEXT NOT NULL,
        to_shop TEXT NOT NULL,
        item_type TEXT NOT NULL,
        qty REAL NOT NULL,
        weight_1 REAL NOT NULL,
        weight_2 REAL NOT NULL
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

    List<String> defaultCats = [
      'चहा',
      'नाश्ता',
      'दाणा',
      'पिशवी',
      'पाणी',
      'Light Bill',
      'Waste Tax',
      'Rent',
      'Labor',
      'Labor food',
      'Self',
      'Other',
    ];
    for (var cat in defaultCats) {
      batch.insert(tableExpenseCategories, {'name': cat, 'is_salary': 0});
    }

    await batch.commit();

    // --- COMPOSITE INDEXES FOR QUERY PERFORMANCE ---
    await db.execute('''
      CREATE INDEX idx_purchases_shop_date ON $tablePurchases (shop_code, date)
    ''');
    await db.execute('''
      CREATE INDEX idx_sales_shop_date ON $tableSales (shop_code, date)
    ''');
    await db.execute('''
      CREATE INDEX idx_expenses_shop_date ON $tableExpenses (shop_code, date)
    ''');
    await db.execute('''
      CREATE INDEX idx_stock_shop_date_item ON $tableStock (shop_code, date, item_type)
    ''');
    await db.execute('''
      CREATE INDEX idx_trader_payments_date ON $tableTraderPayments (date)
    ''');
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

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $tableTraderPayments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          trader_id INTEGER,
          item_type TEXT NOT NULL,
          date TEXT NOT NULL,
          amount REAL NOT NULL,
          notes TEXT,
          FOREIGN KEY (trader_id) REFERENCES $tableTraders (id)
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN broiler_qty INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN mutton_qty INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN dp_qty INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN og_qty INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN pota_kaleji_qty INTEGER NOT NULL DEFAULT 0',
      );
    }

    if (oldVersion < 5) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableExpenseCategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        is_salary INTEGER NOT NULL DEFAULT 0
      )
    ''');
      List<String> defaultCats = [
        'चहा',
        'नाश्ता',
        'दाणा',
        'पिशवी',
        'पाणी',
        'Light Bill',
        'Waste Tax',
        'Rent',
        'Labor',
        'Labor food',
        'Self',
        'Other',
      ];
      for (var cat in defaultCats) {
        try {
          await db.insert(tableExpenseCategories, {
            'name': cat,
            'is_salary': 0,
          });
        } catch (e) {} // Ignores if it already exists
      }

      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN broiler_dead_qty INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN broiler_dead_wt REAL NOT NULL DEFAULT 0.0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN dp_dead_qty INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN dp_dead_wt REAL NOT NULL DEFAULT 0.0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN og_dead_qty INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableSales ADD COLUMN og_dead_wt REAL NOT NULL DEFAULT 0.0',
      );
    }

    if (oldVersion < 6) {
      // Add composite indexes for query performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_purchases_shop_date ON $tablePurchases (shop_code, date)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_sales_shop_date ON $tableSales (shop_code, date)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_expenses_shop_date ON $tableExpenses (shop_code, date)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_stock_shop_date_item ON $tableStock (shop_code, date, item_type)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_trader_payments_date ON $tableTraderPayments (date)
      ''');
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableTransfers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          from_shop TEXT NOT NULL,
          to_shop TEXT NOT NULL,
          item_type TEXT NOT NULL,
          qty REAL NOT NULL,
          weight_1 REAL NOT NULL,
          weight_2 REAL NOT NULL
        )
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_transfers_shops_date ON $tableTransfers (from_shop, to_shop, date)
      ''');
    }
  }
}
