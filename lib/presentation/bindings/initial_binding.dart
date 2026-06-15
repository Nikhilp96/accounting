import 'package:get/get.dart';
import '../../core/database/db_helper.dart';
import '../../data/repositories/repositories.dart';
import '../controllers/dashboard_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core Database
    Get.put(DatabaseHelper.instance, permanent: true);

    // 2. Global Repositories (fenix: true = recreated if disposed, always available)
    Get.lazyPut(() => RateRepository(), fenix: true);
    Get.lazyPut(() => TraderRepository(), fenix: true);
    Get.lazyPut(() => PurchaseRepository(), fenix: true);
    Get.lazyPut(() => SalesRepository(), fenix: true);
    Get.lazyPut(() => ExpenseRepository(), fenix: true);
    Get.lazyPut(() => StockRepository(), fenix: true);
    Get.lazyPut(() => TraderPaymentRepository(), fenix: true);
    Get.lazyPut(() => ExpenseCategoryRepository(), fenix: true);
    Get.lazyPut(() => TransferRepository(), fenix: true);

    // 3. App-Level Controllers
    Get.put(DashboardController()); // Use put() so it initializes immediately on launch
  }
}