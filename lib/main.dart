import 'package:accounting/routes/app_pages.dart';
import 'package:accounting/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'presentation/bindings/initial_binding.dart';

void main() async {
  // Required to ensure native bindings (like SQLite path lookups) 
  // are ready before the app runs.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ShopAccountingApp());
}

class ShopAccountingApp extends StatelessWidget {
  const ShopAccountingApp({super.key});

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