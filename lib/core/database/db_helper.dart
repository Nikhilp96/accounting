import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = "shop_accounting_v2.db";
  static const int _databaseVersion = 1;

  // Table Names
  static const String tableTraders = 'traders';
  static const String tableRates = 'item_rates';
  static const String tablePurchases = 'purchases';
  static const String tableSales = 'sales';

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
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1. Traders Table (For Purchases)
    await db.execute('''
      CREATE TABLE $tableTraders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL -- 'Broiler' or 'Desi'
      )
    ''');

    // 2. Rates Table (Configurable Master Rates)
    await db.execute('''
      CREATE TABLE $tableRates (
        item_name TEXT PRIMARY KEY,
        rate REAL NOT NULL
      )
    ''');

    // 3. Purchases Table
    // We use nullable weight columns so one table handles Broiler, Desi, Eggs, and Pota Kalegi
    await db.execute('''
      CREATE TABLE $tablePurchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_code TEXT NOT NULL, -- 'NK', 'NP', 'PT'
        item_type TEXT NOT NULL, -- 'Broiler', 'Desi', 'Eggs', 'Pota Kalegi'
        date TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        weight_1 REAL, -- Small Chicken / DP Weight
        weight_2 REAL, -- Big Chicken / OG Weight
        rate REAL NOT NULL,
        amount REAL NOT NULL,
        trader_id INTEGER,
        FOREIGN KEY (trader_id) REFERENCES $tableTraders (id)
      )
    ''');

    // 4. Sales Table (Daily/Weekly Entry)
    await db.execute('''
      CREATE TABLE $tableSales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_code TEXT NOT NULL,
        date TEXT NOT NULL,
        broiler_wt REAL NOT NULL,
        mutton_wt REAL NOT NULL,
        dp_wt REAL NOT NULL,
        og_wt REAL NOT NULL,
        egg_qty INTEGER NOT NULL,
        pota_kaleji_wt REAL NOT NULL,
        selling_amount REAL NOT NULL,
        total_amount REAL NOT NULL, -- Manually entered
        difference REAL NOT NULL -- total_amount - selling_amount
      )
    ''');

    // --- SEED INITIAL DATA ---
    
    // Seed Traders
    final batch = db.batch();
    batch.insert(tableTraders, {'name': 'Golden', 'category': 'Broiler'});
    batch.insert(tableTraders, {'name': 'Naim', 'category': 'Broiler'});
    batch.insert(tableTraders, {'name': 'Diamond', 'category': 'Broiler'});
    batch.insert(tableTraders, {'name': 'Arif', 'category': 'Desi'});
    batch.insert(tableTraders, {'name': 'Ansar', 'category': 'Desi'});

    // Seed Fixed Rates
    batch.insert(tableRates, {'item_name': 'Broiler', 'rate': 180.0});
    batch.insert(tableRates, {'item_name': 'Mutton', 'rate': 280.0});
    batch.insert(tableRates, {'item_name': 'DP', 'rate': 260.0});
    batch.insert(tableRates, {'item_name': 'OG', 'rate': 530.0});
    batch.insert(tableRates, {'item_name': 'Eggs', 'rate': 80.0}); // Per Dozen
    batch.insert(tableRates, {'item_name': 'Pota Kalegi', 'rate': 200.0});

    await batch.commit();
  }
}