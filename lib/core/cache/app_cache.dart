import '../../data/models/app_models.dart';
import '../../data/repositories/repositories.dart';

/// Lightweight in-memory cache for frequently-accessed, rarely-changing data.
/// 
/// Caches rates and traders which change only from Settings screen.
/// Invalidates on explicit write. Avoids re-querying on every navigation.
class AppCache {
  static final AppCache _instance = AppCache._internal();
  factory AppCache() => _instance;
  AppCache._internal();

  static AppCache get instance => _instance;

  // --- Cached Data ---
  List<RateModel>? _rates;
  List<TraderModel>? _traders;
  Map<int, String>? _traderNameMap;

  // --- Rates ---
  Future<List<RateModel>> getRates() async {
    if (_rates != null) return _rates!;
    final repo = RateRepository();
    _rates = await repo.getAllRates();
    return _rates!;
  }

  void invalidateRates() {
    _rates = null;
  }

  // --- Traders ---
  Future<List<TraderModel>> getTraders() async {
    if (_traders != null) return _traders!;
    final repo = TraderRepository();
    _traders = await repo.getAllTraders();
    _traderNameMap = null; // Force rebuild of name map
    return _traders!;
  }

  Future<Map<int, String>> getTraderNameMap() async {
    if (_traderNameMap != null) return _traderNameMap!;
    final traders = await getTraders();
    _traderNameMap = {};
    for (var t in traders) {
      if (t.id != null) _traderNameMap![t.id!] = t.name;
    }
    return _traderNameMap!;
  }

  void invalidateTraders() {
    _traders = null;
    _traderNameMap = null;
  }

  /// Invalidate all caches (e.g., after restore from backup)
  void invalidateAll() {
    _rates = null;
    _traders = null;
    _traderNameMap = null;
  }
}
