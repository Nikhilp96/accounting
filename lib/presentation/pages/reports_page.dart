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
        title: Text('Reports - Shop ${controller.shopCode}'),
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
                  return _buildPurchasesView(controller.purchasesList);
                } else if (controller.activeTab.value == 'Sales') {
                  if (controller.salesList.isEmpty) {
                    return _buildEmptyState(
                      'No sales in this period.',
                      Icons.point_of_sale_outlined,
                    );
                  }
                  return _buildSalesTable(controller.salesList);
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
    // Diff > 0 means missing stock (Red). Diff < 0 means surplus (Green).
    Color diffColor = values['Difference']! > 0.01
        ? Colors.red.shade700
        : (values['Difference']! < -0.01
              ? Colors.green.shade700
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
  Widget _buildPurchasesView(List<PurchaseModel> allPurchases) {
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
        _buildCategoryTable('Broiler', broilerList, Colors.orange.shade800),
        _buildCategoryTable('Desi', desiList, Colors.brown.shade800),
        _buildCategoryTable('Eggs', eggsList, Colors.amber.shade900),
        _buildCategoryTable('Pota Kalegi', potaList, Colors.red.shade800),
      ],
    );
  }

  // --- DYNAMIC CATEGORY TABLE BUILDER ---
  Widget _buildCategoryTable(
    String title,
    List<PurchaseModel> data,
    Color themeColor,
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
        color: MaterialStateProperty.all(themeColor.withOpacity(0.1)),
        cells: totalCells,
      ),
    );

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
        color: MaterialStateProperty.all(Colors.blue.withOpacity(0.05)),
        cells: openCells,
      ),
    );

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
        color: MaterialStateProperty.all(Colors.orange.withOpacity(0.05)),
        cells: closeCells,
      ),
    );

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
                    (controller.stockMap['Closing_${title}_Qty'] ?? 0.0))
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
              '${(totalWt1 + (controller.stockMap['Opening_${title}_Wt1'] ?? 0.0) - (controller.stockMap['Closing_${title}_Wt1'] ?? 0.0)).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        DataCell(
          Obx(
            () => Text(
              '${(totalWt2 + (controller.stockMap['Opening_${title}_Wt2'] ?? 0.0) - (controller.stockMap['Closing_${title}_Wt2'] ?? 0.0)).toStringAsFixed(2)}',
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
        color: MaterialStateProperty.all(themeColor.withOpacity(0.2)),
        cells: actualCells,
      ),
    );

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
          Container(
            color: themeColor.withOpacity(0.15),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: themeColor, size: 20),
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
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
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
}
