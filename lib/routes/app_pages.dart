import 'package:accounting/presentation/pages/dashboard_page.dart';
import 'package:accounting/presentation/pages/expense_entry_page.dart';
import 'package:accounting/presentation/pages/purchase_entry_page.dart';
import 'package:accounting/presentation/pages/reports_page.dart';
import 'package:accounting/presentation/pages/sales_entry_page.dart';
import 'package:accounting/presentation/pages/settings_screen.dart';
import 'package:accounting/presentation/pages/shop_home_page.dart';
import 'package:accounting/presentation/pages/transfer_entry_page.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  // Prevent instantiation
  AppPages._();

  static final pages = [
    GetPage(name: Routes.DASHBOARD, page: () => const DashboardPage()),
    GetPage(name: Routes.SHOP_HOME, page: () => const ShopHomePage()),
    GetPage(name: Routes.SETTINGS, page: () => const SettingsScreen()),
    GetPage(name: Routes.PURCHASE_ENTRY, page: () => const PurchaseEntryPage()),
    GetPage(name: Routes.SALES_ENTRY, page: () => const SalesEntryPage()),
    GetPage(name: Routes.REPORTS, page: () => const ReportsPage()),
    GetPage(name: Routes.EXPENSE_ENTRY, page: () => const ExpenseEntryPage()),
    GetPage(
      name: Routes.TRANSFER_ENTRY,
      page: () => const TransferEntryPage(),
    ),
  ];
}
