import 'package:accounting/routes/app_pages.dart';
import 'package:accounting/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/utils/backup_manager.dart';
import 'presentation/bindings/initial_binding.dart';

void main() async {
  // Required to ensure native bindings (like SQLite path lookups) 
  // are ready before the app runs.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ShopAccountingApp());
}

class ShopAccountingApp extends StatefulWidget {
  const ShopAccountingApp({super.key});

  @override
  State<ShopAccountingApp> createState() => _ShopAccountingAppState();
}

class _ShopAccountingAppState extends State<ShopAccountingApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackupManager.instance.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flush any pending backup when the app goes to background or is about to close
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      BackupManager.instance.flushNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shop Accounting',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      
      // Inject global dependencies (Database, Repositories, Controllers)
      initialBinding: InitialBinding(),
      
      // Routing
      initialRoute: Routes.DASHBOARD,
      getPages: AppPages.pages,
    );
  }
}