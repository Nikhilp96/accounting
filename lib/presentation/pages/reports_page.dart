import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../data/models/app_models.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Softer background
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Obx(
          () => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.shopCode.value,
              dropdownColor: Colors.brown.shade800,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              items: controller.availableShops.map((String shop) {
                return DropdownMenuItem<String>(
                  value: shop,
                  child: Text('Reports - Shop $shop'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.shopCode.value = newValue;
                }
              },
            ),
          ),
        ),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'export') {
                controller.exportReportToExcel();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.green),
                    SizedBox(width: 12),
                    Text(
                      'Export to Excel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildControlHeader(context, controller),
              const SizedBox(height: 8),

              // --- Summary Dashboard ---
              _buildAnalysisCard(controller),
              _buildTraderPayablesCard(controller),
              _buildBirdsEyeView(controller),
              const SizedBox(height: 16),

              // --- Segmented Tab Toggle ---
              _buildModernTabBar(controller),
              const SizedBox(height: 12),

              // --- Data Tables ---
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.brown),
                    ),
                  );
                }

                if (controller.activeTab.value == 'Purchases') {
                  if (controller.purchasesList.isEmpty) {
                    return _buildEmptyState(
                      'No purchases in this period.',
                      Icons.shopping_cart_outlined,
                    );
                  }
                  return _buildPurchasesView(controller.purchasesList, context);
                } else if (controller.activeTab.value == 'Sales') {
                  if (controller.salesList.isEmpty) {
                    return _buildEmptyState(
                      'No sales in this period.',
                      Icons.point_of_sale_outlined,
                    );
                  }
                  return Column(
                    children: [
                      _buildSalesTable(controller.salesList),
                      _buildMortalityTable(controller.salesList),
                    ],
                  );
                } else {
                  if (controller.expensesList.isEmpty) {
                    return _buildEmptyState(
                      'No expenses in this period.',
                      Icons.money_off_outlined,
                    );
                  }
                  return _buildExpensesTable(controller.expensesList);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---

  // Reusable Empty State Widget
  Widget _buildEmptyState(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Control Header
  Widget _buildControlHeader(
    BuildContext context,
    ReportsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // View Mode Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(
              () => DropdownButton<String>(
                value: controller.viewMode.value,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.brown,
                ),
                items: ['Daily', 'Weekly'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) => controller.viewMode.value = newValue!,
                underline: const SizedBox(),
              ),
            ),
          ),

          // Date Picker Button
          InkWell(
            onTap: () => controller.pickDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.brown,
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => Text(
                      controller.dateDisplay,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modern Segmented Tab Bar
  Widget _buildModernTabBar(ReportsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Purchases', controller)),
          Expanded(child: _buildTabButton('Sales', controller)),
          Expanded(child: _buildTabButton('Expenses', controller)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, ReportsController controller) {
    return Obx(() {
      bool isActive = controller.activeTab.value == title;
      return GestureDetector(
        onTap: () => controller.activeTab.value = title,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.brown.shade700 : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );
    });
  }

  // --- Financial Analysis Card ---
  Widget _buildAnalysisCard(ReportsController controller) {
    return Obx(() {
      Color netColor = controller.netPosition >= 0
          ? Colors.green.shade700
          : Colors.red.shade700;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: CircleAvatar(
            backgroundColor: Colors.brown.shade50,
            child: const Icon(Icons.analytics_outlined, color: Colors.brown),
          ),
          title: const Text(
            'Period Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          subtitle: Text(
            'Net Cash: ₹${controller.netPosition.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: netColor,
              fontSize: 14,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Total Collected Sales:',
                    controller.totalCollectedSales,
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Total Purchases:',
                    controller.totalPurchases,
                    Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Weekly Expenses:',
                    controller.totalWeeklyExpenses,
                    Colors.orange.shade800,
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Cash Position:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: netColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹${controller.netPosition.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: netColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (controller.salesDifference != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        '*Sales Shortage/Excess vs System: ₹${controller.salesDifference.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- Trader Payables Card ---
  Widget _buildTraderPayablesCard(ReportsController controller) {
    return Obx(() {
      if (controller.traderPayables.isEmpty) return const SizedBox.shrink();

      double grandTotal = controller.traderPayables.values.fold(
        0.0,
        (sum, val) => sum + val,
      );

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: CircleAvatar(
            backgroundColor: Colors.indigo.shade50,
            child: const Icon(Icons.storefront_outlined, color: Colors.indigo),
          ),
          title: const Text(
            'Amount Payable to Traders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          subtitle: Text(
            'Grand Total: ₹${grandTotal.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              fontSize: 14,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: controller.traderPayables.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${entry.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- Bird's Eye View Card ---
  Widget _buildBirdsEyeView(ReportsController controller) {
    return Obx(() {
      final data = controller.birdsEyeView;
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: CircleAvatar(
            backgroundColor: Colors.teal.shade50,
            child: const Icon(Icons.visibility_outlined, color: Colors.teal),
          ),
          title: const Text(
            'Weekly Bird\'s Eye View (kg)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Item',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Pur',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Sales',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Dead',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Text(
                              'Diff',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBirdRow('Broiler', data['Broiler']!),
                  _buildBirdRow('DP', data['DP']!),
                  _buildBirdRow('OG', data['OG']!),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Helper for Summary Rows
  Widget _buildSummaryRow(String title, double amount, Color amountColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(color: amountColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBirdRow(String label, Map<String, double> values) {
    // Diff < 0 means missing stock (Red). Diff > 0 means surplus (Green).
    Color diffColor = values['Difference']! > 0.01
        ? Colors.green.shade700
        : (values['Difference']! < -0.01
              ? Colors.red.shade700
              : Colors.black54);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              values['Purchase']!.toStringAsFixed(1),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              values['Sales']!.toStringAsFixed(1),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              values['Dead']!.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                values['Difference']!.toStringAsFixed(1),
                textAlign: TextAlign.right,
                style: TextStyle(color: diffColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MULTI-TABLE PURCHASES VIEW ---
  Widget _buildPurchasesView(
    List<PurchaseModel> allPurchases,
    BuildContext context,
  ) {
    final broilerList = allPurchases
        .where((p) => p.itemType == 'Broiler')
        .toList();
    final desiList = allPurchases.where((p) => p.itemType == 'Desi').toList();
    final eggsList = allPurchases.where((p) => p.itemType == 'Eggs').toList();
    final potaList = allPurchases
        .where((p) => p.itemType == 'Pota Kalegi')
        .toList();

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      children: [
        _buildCategoryTable(
          'Broiler',
          broilerList,
          Colors.orange.shade800,
          context,
        ),
        _buildCategoryTable('Desi', desiList, Colors.brown.shade800, context),
        _buildCategoryTable('Eggs', eggsList, Colors.amber.shade900, context),
        _buildCategoryTable(
          'Pota Kalegi',
          potaList,
          Colors.red.shade800,
          context,
        ),
      ],
    );
  }

  // --- DYNAMIC CATEGORY TABLE BUILDER ---
  Widget _buildCategoryTable(
    String title,
    List<PurchaseModel> data,
    Color themeColor,
    BuildContext context,
  ) {
    final controller = Get.find<ReportsController>();
    bool isBird = title == 'Broiler' || title == 'Desi';

    List<DataRow> rows = data.map((item) {
      String traderName = item.traderId != null
          ? controller.traderMap[item.traderId] ?? '-'
          : '-';

      List<DataCell> cells = [
        DataCell(Text(DateUtil.formatIso(item.date))),
        DataCell(Text(traderName)),
        DataCell(Text(item.quantity.toString())),
      ];
      if (isBird) {
        cells.addAll([
          DataCell(Text(item.weight1?.toStringAsFixed(2) ?? '-')),
          DataCell(Text(item.weight2?.toStringAsFixed(2) ?? '-')),
        ]);
      }
      cells.addAll([
        DataCell(Text('₹${item.rate.toStringAsFixed(2)}')),
        DataCell(
          Text(
            '₹${item.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                onPressed: () => controller.editPurchase(item),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                onPressed: () => _confirmDelete(
                  Get.context!,
                  () => controller.deletePurchaseRecord(item.id!),
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ),
      ]);
      return DataRow(cells: cells);
    }).toList();

    double totalQty = data.fold(0.0, (sum, item) => sum + item.quantity);
    double totalWt1 = isBird
        ? data.fold(0.0, (sum, item) => sum + (item.weight1 ?? 0.0))
        : 0.0;
    double totalWt2 = isBird
        ? data.fold(0.0, (sum, item) => sum + (item.weight2 ?? 0.0))
        : 0.0;
    double totalAmt = data.fold(0.0, (sum, item) => sum + item.amount);

    // TOTAL ROW
    List<DataCell> totalCells = [
      const DataCell(
        Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataCell(Text('-')),
      DataCell(
        Text(
          totalQty.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    ];
    if (isBird) {
      totalCells.addAll([
        DataCell(
          Text(
            totalWt1.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        DataCell(
          Text(
            totalWt2.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ]);
    }
    totalCells.addAll([
      const DataCell(Text('-')),
      DataCell(
        Text(
          '₹${totalAmt.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: themeColor,
          ),
        ),
      ),
      const DataCell(Text('-')),
    ]);
    rows.add(
      DataRow(
        color: WidgetStateProperty.all(themeColor.withOpacity(0.1)),
        cells: totalCells,
      ),
    );

    // OPENING STOCK
    List<DataCell> openCells = [
      DataCell(
        Text(
          '[+] OPENING STOCK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
            fontSize: 13,
          ),
        ),
      ),
      const DataCell(Text('-')),
      _buildStockInputCell(controller, 'Opening', title, 'Qty'),
    ];
    if (isBird) {
      openCells.addAll([
        _buildStockInputCell(controller, 'Opening', title, 'Wt1'),
        _buildStockInputCell(controller, 'Opening', title, 'Wt2'),
      ]);
    }
    openCells.addAll([
      const DataCell(Text('-')),
      const DataCell(Text('-')),
      const DataCell(Text('-')),
    ]);
    rows.add(
      DataRow(
        color: WidgetStateProperty.all(Colors.blue.withOpacity(0.05)),
        cells: openCells,
      ),
    );

    // CLOSING STOCK
    List<DataCell> closeCells = [
      DataCell(
        Text(
          '[-] CLOSING STOCK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
            fontSize: 13,
          ),
        ),
      ),
      const DataCell(Text('-')),
      _buildStockInputCell(controller, 'Closing', title, 'Qty'),
    ];
    if (isBird) {
      closeCells.addAll([
        _buildStockInputCell(controller, 'Closing', title, 'Wt1'),
        _buildStockInputCell(controller, 'Closing', title, 'Wt2'),
      ]);
    }
    closeCells.addAll([
      const DataCell(Text('-')),
      const DataCell(Text('-')),
      DataCell(
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.save, size: 16),
          label: const Text('Save'),
          onPressed: () => controller.saveStockData(title),
        ),
      ),
    ]);
    rows.add(
      DataRow(
        color: WidgetStateProperty.all(Colors.orange.withOpacity(0.05)),
        cells: closeCells,
      ),
    );

    // --- NEW: DYNAMIC TRANSFER ROWS BY SHOP ---
    List<String> otherShops = [
      'NK',
      'NP',
      'PT',
    ].where((s) => s != controller.shopCode.value).toList();

    // Generate RECEIVED rows for each other shop
    for (String otherShop in otherShops) {
      List<DataCell> rxCells = [
        DataCell(
          Text(
            '[+] RECEIVED FROM $otherShop',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
              fontSize: 13,
            ),
          ),
        ),
        const DataCell(Text('-')),
        DataCell(
          Obx(
            () => Text(
              controller
                  .getTransferTotal(
                    title,
                    'Qty',
                    isReceived: true,
                    otherShop: otherShop,
                  )
                  .toStringAsFixed(2),
              style: TextStyle(
                color: Colors.teal.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
      if (isBird) {
        rxCells.addAll([
          DataCell(
            Obx(
              () => Text(
                controller
                    .getTransferTotal(
                      title,
                      'Wt1',
                      isReceived: true,
                      otherShop: otherShop,
                    )
                    .toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.teal.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          DataCell(
            Obx(
              () => Text(
                controller
                    .getTransferTotal(
                      title,
                      'Wt2',
                      isReceived: true,
                      otherShop: otherShop,
                    )
                    .toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.teal.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ]);
      }
      rxCells.addAll([
        const DataCell(Text('-')), // Rate
        const DataCell(Text('-')), // Amount
        DataCell(
          IconButton(
            icon: Icon(Icons.list_alt, color: Colors.teal.shade700, size: 20),
            onPressed: () => _showTransferHistoryDialog(
              context,
              controller,
              title,
              isReceived: true,
              otherShop: otherShop,
            ),
            tooltip: 'View Transfer History',
          ),
        ),
      ]);
      rows.add(
        DataRow(
          color: WidgetStateProperty.all(Colors.teal.withOpacity(0.05)),
          cells: rxCells,
        ),
      );
    }

    // Generate SENT rows for each other shop
    for (String otherShop in otherShops) {
      List<DataCell> txCells = [
        DataCell(
          Text(
            '[-] SENT TO $otherShop',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
              fontSize: 13,
            ),
          ),
        ),
        const DataCell(Text('-')),
        DataCell(
          Obx(
            () => Text(
              controller
                  .getTransferTotal(
                    title,
                    'Qty',
                    isReceived: false,
                    otherShop: otherShop,
                  )
                  .toStringAsFixed(2),
              style: TextStyle(
                color: Colors.purple.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
      if (isBird) {
        txCells.addAll([
          DataCell(
            Obx(
              () => Text(
                controller
                    .getTransferTotal(
                      title,
                      'Wt1',
                      isReceived: false,
                      otherShop: otherShop,
                    )
                    .toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          DataCell(
            Obx(
              () => Text(
                controller
                    .getTransferTotal(
                      title,
                      'Wt2',
                      isReceived: false,
                      otherShop: otherShop,
                    )
                    .toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ]);
      }
      txCells.addAll([
        const DataCell(Text('-')), // Rate
        const DataCell(Text('-')), // Amount
        DataCell(
          IconButton(
            icon: Icon(Icons.list_alt, color: Colors.purple.shade700, size: 20),
            onPressed: () => _showTransferHistoryDialog(
              context,
              controller,
              title,
              isReceived: false,
              otherShop: otherShop,
            ),
            tooltip: 'View Transfer History',
          ),
        ),
      ]);
      rows.add(
        DataRow(
          color: WidgetStateProperty.all(Colors.purple.withOpacity(0.05)),
          cells: txCells,
        ),
      );
    }

    // ACTUAL ROW (Uses overall Transfer Totals)
    List<DataCell> actualCells = [
      const DataCell(
        Text(
          '= ACTUAL',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      const DataCell(Text('-')),
      DataCell(
        Obx(
          () => Text(
            (totalQty +
                    (controller.stockMap['Opening_${title}_Qty'] ?? 0.0) -
                    (controller.stockMap['Closing_${title}_Qty'] ?? 0.0) +
                    controller.getTransferTotal(
                      title,
                      'Qty',
                      isReceived: true,
                    ) - // Total across all shops
                    controller.getTransferTotal(
                      title,
                      'Qty',
                      isReceived: false,
                    )) // Total across all shops
                .toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    ];
    if (isBird) {
      actualCells.addAll([
        DataCell(
          Obx(
            () => Text(
              (totalWt1 +
                      (controller.stockMap['Opening_${title}_Wt1'] ?? 0.0) -
                      (controller.stockMap['Closing_${title}_Wt1'] ?? 0.0) +
                      controller.getTransferTotal(
                        title,
                        'Wt1',
                        isReceived: true,
                      ) -
                      controller.getTransferTotal(
                        title,
                        'Wt1',
                        isReceived: false,
                      ))
                  .toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        DataCell(
          Obx(
            () => Text(
              (totalWt2 +
                      (controller.stockMap['Opening_${title}_Wt2'] ?? 0.0) -
                      (controller.stockMap['Closing_${title}_Wt2'] ?? 0.0) +
                      controller.getTransferTotal(
                        title,
                        'Wt2',
                        isReceived: true,
                      ) -
                      controller.getTransferTotal(
                        title,
                        'Wt2',
                        isReceived: false,
                      ))
                  .toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ]);
    }
    actualCells.addAll([
      const DataCell(Text('-')),
      const DataCell(Text('-')),
      const DataCell(Text('-')),
    ]);
    rows.add(
      DataRow(
        color: WidgetStateProperty.all(themeColor.withOpacity(0.2)),
        cells: actualCells,
      ),
    );

    // Columns
    List<DataColumn> columns = [
      const DataColumn(
        label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Trader', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
    if (isBird) {
      columns.addAll([
        DataColumn(
          label: Text(
            title == 'Broiler' ? 'Small Wt' : 'DP Wt',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            title == 'Broiler' ? 'Big Wt' : 'OG Wt',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]);
    }
    columns.addAll([
      const DataColumn(
        label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ]);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER WITH TRANSFER BUTTON
          Container(
            color: themeColor.withOpacity(0.15),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: themeColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$title Ledger',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showTransferDialog(context, controller, title),
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Transfer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
              dataRowMinHeight: 40,
              dataRowMaxHeight: 50,
              columnSpacing: 24,
              columns: columns,
              rows: rows,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(
    BuildContext context,
    ReportsController controller,
    String itemType, {
    TransferModel? editData,
  }) {
    bool isEdit = editData != null;

    // Pre-fill states based on whether we are editing or creating
    bool isSending = isEdit
        ? (editData.fromShop == controller.shopCode.value)
        : true;
    String selectedShop = isEdit
        ? (isSending ? editData.toShop : editData.fromShop)
        : (controller.shopCode.value == 'NK' ? 'NP' : 'NK');

    List<String> availableShops = [
      'NK',
      'NP',
      'PT',
    ].where((s) => s != controller.shopCode.value).toList();

    // Pre-fill controllers if editing
    final qtyCtrl = TextEditingController(
      text: isEdit && editData.qty > 0 ? editData.qty.toString() : '',
    );
    final wt1Ctrl = TextEditingController(
      text: isEdit && editData.weight1 > 0 ? editData.weight1.toString() : '',
    );
    final wt2Ctrl = TextEditingController(
      text: isEdit && editData.weight2 > 0 ? editData.weight2.toString() : '',
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setState) {
            // Dynamic theme colors based on the selected action
            Color actionColor = isSending
                ? Colors.purple.shade600
                : Colors.teal.shade600;
            Color bgColor = isSending
                ? Colors.purple.shade50
                : Colors.teal.shade50;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- HEADER ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSending ? Icons.call_made : Icons.call_received,
                            color: actionColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transfer $itemType',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isSending
                                    ? 'Move stock out'
                                    : 'Receive stock in',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- MODERN SEGMENTED TOGGLE ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isSending = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSending
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isSending
                                      ? [
                                          const BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Send Items',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSending
                                        ? Colors.purple.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isSending = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !isSending
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: !isSending
                                      ? [
                                          const BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Receive Items',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !isSending
                                        ? Colors.teal.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- SHOP SELECTION ---
                    DropdownButtonFormField<String>(
                      value: selectedShop,
                      decoration: InputDecoration(
                        labelText: isSending
                            ? 'Destination Shop'
                            : 'Source Shop',
                        prefixIcon: const Icon(Icons.storefront_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: availableShops
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text('Shop $s'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedShop = v!),
                    ),
                    const SizedBox(height: 16),

                    // --- QUANTITY FIELD ---
                    TextField(
                      controller: qtyCtrl,
                      decoration: InputDecoration(
                        labelText: 'Quantity (Pcs)',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    // --- WEIGHT FIELDS (IF BIRD) ---
                    if (itemType == 'Broiler' || itemType == 'Desi') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: wt1Ctrl,
                              decoration: InputDecoration(
                                labelText: itemType == 'Broiler'
                                    ? 'Small Wt'
                                    : 'DP Wt',
                                prefixIcon: const Icon(
                                  Icons.scale_outlined,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (val) {
                                if ((double.tryParse(val) ?? 0) > 0) {
                                  wt2Ctrl.clear();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: wt2Ctrl,
                              decoration: InputDecoration(
                                labelText: itemType == 'Broiler'
                                    ? 'Big Wt'
                                    : 'OG Wt',
                                prefixIcon: const Icon(
                                  Icons.scale_outlined,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (val) {
                                if ((double.tryParse(val) ?? 0) > 0) {
                                  wt1Ctrl.clear();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),

                    // --- ACTION BUTTONS ---
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              double qty = double.tryParse(qtyCtrl.text) ?? 0;
                              double wt1 = double.tryParse(wt1Ctrl.text) ?? 0;
                              double wt2 = double.tryParse(wt2Ctrl.text) ?? 0;

                              // --- VALIDATION RULES ---
                              if (qty <= 0 && wt1 <= 0 && wt2 <= 0) {
                                Get.snackbar(
                                  'Validation Error',
                                  'Please enter a valid quantity or weight to proceed.',
                                  backgroundColor: Colors.red.shade800,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(16),
                                  icon: const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                  ),
                                );
                                return; // Stop execution
                              }

                              // If valid, execute save and dismiss
                              if (isEdit) {
                                final updatedTransfer = TransferModel(
                                  id: editData.id,
                                  date: editData
                                      .date, // Retain original timestamp
                                  fromShop: isSending
                                      ? controller.shopCode.value
                                      : selectedShop,
                                  toShop: isSending
                                      ? selectedShop
                                      : controller.shopCode.value,
                                  itemType: itemType,
                                  qty: qty,
                                  weight1: wt1,
                                  weight2: wt2,
                                );
                                controller.updateTransferRecord(
                                  updatedTransfer,
                                );
                              } else {
                                controller.saveTransfer(
                                  itemType,
                                  isSending,
                                  selectedShop,
                                  qty,
                                  wt1,
                                  wt2,
                                );
                              }
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: actionColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(isSending ? Icons.send : Icons.download),
                            label: const Text(
                              'Confirm',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- HELPER: Editable Text Input for the Table Cell ---
  DataCell _buildStockInputCell(
    ReportsController controller,
    String type,
    String itemType,
    String field, {
    bool isInt = false,
  }) {
    String mapKey = '${type}_${itemType}_$field';
    String currentVal = isInt
        ? (controller.stockMap[mapKey] ?? 0).toString()
        : (controller.stockMap[mapKey] ?? 0.0).toStringAsFixed(2);
    if (currentVal == '0' || currentVal == '0.00') currentVal = '';

    return DataCell(
      SizedBox(
        width: 65, // Slightly wider for ease of typing
        child: TextFormField(
          key: ValueKey('${mapKey}_${controller.dateDisplay}'),
          initialValue: currentVal,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          onChanged: (val) {
            if (isInt) {
              controller.stockMap[mapKey] = int.tryParse(val) ?? 0;
            } else {
              controller.stockMap[mapKey] = double.tryParse(val) ?? 0.0;
            }
          },
          style: TextStyle(
            color: type == 'Opening'
                ? Colors.blue.shade700
                : Colors.orange.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  // --- SALES DATATABLE ---
  Widget _buildSalesTable(List<SaleModel> data) {
    List<DataRow> rows = data.map((sale) {
      Color diffColor = sale.difference >= 0
          ? Colors.green.shade700
          : Colors.red.shade700;
      return DataRow(
        cells: [
          DataCell(Text(DateUtil.formatIso(sale.date))),
          DataCell(
            Text('${sale.broilerQty} / ${sale.broilerWt.toStringAsFixed(2)}'),
          ), // Combined
          DataCell(
            Text('${sale.muttonQty} / ${sale.muttonWt.toStringAsFixed(2)}'),
          ), // Combined
          DataCell(
            Text('${sale.dpQty} / ${sale.dpWt.toStringAsFixed(2)}'),
          ), // Combined
          DataCell(
            Text('${sale.ogQty} / ${sale.ogWt.toStringAsFixed(2)}'),
          ), // Combined
          DataCell(Text(sale.eggQty.toString())),
          DataCell(
            Text(
              '${sale.potaKalejiQty} / ${sale.potaKalejiWt.toStringAsFixed(2)}',
            ),
          ), // Combined
          DataCell(Text('₹${sale.sellingAmount.toStringAsFixed(2)}')),
          DataCell(
            Text(
              '₹${sale.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: diffColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '₹${sale.difference.toStringAsFixed(2)}',
                style: TextStyle(color: diffColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  onPressed: () => Get.find<ReportsController>().editSale(sale),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(
                    Get.context!,
                    () => Get.find<ReportsController>().deleteSalesRecord(
                      sale.id!,
                    ),
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    double totBroiler = data.fold(0.0, (sum, item) => sum + item.broilerWt);
    int totBroilerQty = data.fold(0, (sum, item) => sum + item.broilerQty);

    double totMutton = data.fold(0.0, (sum, item) => sum + item.muttonWt);
    int totMuttonQty = data.fold(0, (sum, item) => sum + item.muttonQty);

    double totDp = data.fold(0.0, (sum, item) => sum + item.dpWt);
    int totDpQty = data.fold(0, (sum, item) => sum + item.dpQty);

    double totOg = data.fold(0.0, (sum, item) => sum + item.ogWt);
    int totOgQty = data.fold(0, (sum, item) => sum + item.ogQty);

    int totEggs = data.fold(0, (sum, item) => sum + item.eggQty);

    double totPota = data.fold(0.0, (sum, item) => sum + item.potaKalejiWt);
    int totPotaQty = data.fold(0, (sum, item) => sum + item.potaKalejiQty);
    double totSys = data.fold(0.0, (sum, item) => sum + item.sellingAmount);
    double totCol = data.fold(0.0, (sum, item) => sum + item.totalAmount);
    double totDiff = data.fold(0.0, (sum, item) => sum + item.difference);

    Color finalDiffColor = totDiff >= 0
        ? Colors.green.shade800
        : Colors.red.shade800;

    rows.add(
      DataRow(
        color: MaterialStateProperty.all(Colors.indigo.shade50),
        cells: [
          const DataCell(
            Text(
              'TOTAL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          DataCell(
            Text(
              '$totBroilerQty / ${totBroiler.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              '$totMuttonQty / ${totMutton.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              '$totDpQty / ${totDp.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              '$totOgQty / ${totOg.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              totEggs.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              '$totPotaQty / ${totPota.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              '₹${totSys.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              '₹${totCol.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          DataCell(
            Text(
              '₹${totDiff.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: finalDiffColor,
              ),
            ),
          ),
          const DataCell(Text('-')),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          dataRowMinHeight: 40,
          dataRowMaxHeight: 50,
          columnSpacing: 20,
          columns: const [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Broiler\n(Q/W)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Mutton\n(Q/W)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'DP\n(Q/W)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'OG\n(Q/W)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Eggs',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Pota\n(Q/W)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Sys Amt',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Collected',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Diff',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Action',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: rows,
        ),
      ),
    );
  }

  // --- MORTALITY DATATABLE ---
  Widget _buildMortalityTable(List<SaleModel> data) {
    // Check if there's any mortality data at all
    bool hasMortality = data.any(
      (s) =>
          s.broilerDeadQty > 0 ||
          s.broilerDeadWt > 0 ||
          s.dpDeadQty > 0 ||
          s.dpDeadWt > 0 ||
          s.ogDeadQty > 0 ||
          s.ogDeadWt > 0,
    );

    if (!hasMortality) return const SizedBox.shrink();

    List<DataRow> rows = data
        .where(
          (s) =>
              s.broilerDeadQty > 0 ||
              s.broilerDeadWt > 0 ||
              s.dpDeadQty > 0 ||
              s.dpDeadWt > 0 ||
              s.ogDeadQty > 0 ||
              s.ogDeadWt > 0,
        )
        .map((sale) {
          return DataRow(
            cells: [
              DataCell(Text(DateUtil.formatIso(sale.date))),
              DataCell(
                Text(
                  sale.broilerDeadQty > 0
                      ? '${sale.broilerDeadQty} / ${sale.broilerDeadWt.toStringAsFixed(2)}'
                      : '-',
                ),
              ),
              DataCell(
                Text(
                  sale.dpDeadQty > 0
                      ? '${sale.dpDeadQty} / ${sale.dpDeadWt.toStringAsFixed(2)}'
                      : '-',
                ),
              ),
              DataCell(
                Text(
                  sale.ogDeadQty > 0
                      ? '${sale.ogDeadQty} / ${sale.ogDeadWt.toStringAsFixed(2)}'
                      : '-',
                ),
              ),
            ],
          );
        })
        .toList();

    // Totals row
    int totBroilerDeadQty = data.fold(0, (sum, s) => sum + s.broilerDeadQty);
    double totBroilerDeadWt = data.fold(0.0, (sum, s) => sum + s.broilerDeadWt);
    int totDpDeadQty = data.fold(0, (sum, s) => sum + s.dpDeadQty);
    double totDpDeadWt = data.fold(0.0, (sum, s) => sum + s.dpDeadWt);
    int totOgDeadQty = data.fold(0, (sum, s) => sum + s.ogDeadQty);
    double totOgDeadWt = data.fold(0.0, (sum, s) => sum + s.ogDeadWt);

    rows.add(
      DataRow(
        color: WidgetStateProperty.all(Colors.red.shade50),
        cells: [
          const DataCell(
            Text(
              'TOTAL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          DataCell(
            Text(
              '$totBroilerDeadQty / ${totBroilerDeadWt.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              '$totDpDeadQty / ${totDpDeadWt.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              '$totOgDeadQty / ${totOgDeadWt.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.red.shade50,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mortality / Dead Stock',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
              dataRowMinHeight: 40,
              dataRowMaxHeight: 50,
              columnSpacing: 24,
              columns: const [
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Broiler\n(Q / Wt)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'DP\n(Q / Wt)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'OG\n(Q / Wt)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: rows,
            ),
          ),
        ],
      ),
    );
  }

  // --- EXPENSES DATATABLE ---
  Widget _buildExpensesTable(List<ExpenseModel> data) {
    List<DataRow> rows = data.map((expense) {
      return DataRow(
        cells: [
          DataCell(Text(DateUtil.formatIso(expense.date))),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                expense.category,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  onPressed: () =>
                      Get.find<ReportsController>().editExpense(expense),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(
                    Get.context!,
                    () => Get.find<ReportsController>().deleteExpenseRecord(
                      expense.id!,
                    ),
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    double totalAmt = data.fold(0.0, (sum, item) => sum + item.amount);

    rows.add(
      DataRow(
        color: MaterialStateProperty.all(Colors.orange.shade100),
        cells: [
          const DataCell(
            Text(
              'TOTAL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const DataCell(Text('-')),
          // Removed the extra blank DataCell for Notes
          DataCell(
            Text(
              '₹${totalAmt.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.orange.shade900,
              ),
            ),
          ),
          const DataCell(Text('-')),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          dataRowMinHeight: 45,
          dataRowMaxHeight: 55,
          columnSpacing: 24,
          columns: const [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Removed the Notes DataColumn
            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Action',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: rows,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Delete Record',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText:
          'Are you sure? This will permanently delete the record and update the Excel backup.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      cancelTextColor: Colors.grey.shade800,
      radius: 12,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }

  void _showTransferHistoryDialog(
    BuildContext context,
    ReportsController controller,
    String itemType, {
    required bool isReceived,
    required String otherShop,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    isReceived ? Icons.call_received : Icons.call_made,
                    color: isReceived ? Colors.teal : Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isReceived
                          ? 'Received from $otherShop'
                          : 'Sent to $otherShop',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Flexible(
                child: Obx(() {
                  // Filter individual transfers
                  var filtered = controller.transfersList.where((t) {
                    bool matchesShop = isReceived
                        ? t.toShop == controller.shopCode.value
                        : t.fromShop == controller.shopCode.value;
                    bool matchesOther = isReceived
                        ? t.fromShop == otherShop
                        : t.toShop == otherShop;
                    return matchesShop &&
                        matchesOther &&
                        t.itemType == itemType;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No transfers found.'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      var t = filtered[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Qty: ${t.qty}  |  Wt 1: ${t.weight1}  |  Wt 2: ${t.weight2}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          DateUtil.formatIso(t.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              onPressed: () {
                                Get.back(); // Close history dialog
                                _showTransferDialog(
                                  context,
                                  controller,
                                  itemType,
                                  editData: t,
                                ); // Open edit dialog
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              onPressed: () {
                                _confirmDelete(context, () {
                                  controller.deleteTransferRecord(t.id!);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
