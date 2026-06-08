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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Reports - Shop ${controller.shopCode}'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildControlHeader(context, controller),
              _buildAnalysisCard(controller),
              _buildTraderPayablesCard(controller),
              _buildBirdsEyeView(controller),
              SizedBox(height: 10),
              // Tab Toggle
              Obx(
                () => Row(
                  children: [
                    Expanded(child: _buildTabButton('Purchases', controller)),
                    Expanded(child: _buildTabButton('Sales', controller)),
                    Expanded(child: _buildTabButton('Expenses', controller)),
                  ],
                ),
              ),

              // Data Table
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.activeTab.value == 'Purchases') {
                  if (controller.purchasesList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('No purchases in this period.'),
                      ),
                    );
                  }
                  return _buildPurchasesView(controller.purchasesList);
                } else if (controller.activeTab.value == 'Sales') {
                  if (controller.salesList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No sales in this period.')),
                    );
                  }
                  return _buildSalesTable(controller.salesList);
                } else {
                  // --- EXPENSES TAB LOGIC ---
                  if (controller.expensesList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No expenses in this period.')),
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

  // --- Header & Controls ---
  Widget _buildControlHeader(
    BuildContext context,
    ReportsController controller,
  ) {
    return Container(
      color: Colors.brown.shade50,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Daily / Weekly Dropdown
          Obx(
            () => DropdownButton<String>(
              value: controller.viewMode.value,
              items: ['Daily', 'Weekly'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (newValue) => controller.viewMode.value = newValue!,
              underline: const SizedBox(),
            ),
          ),

          // Date Picker Button
          ElevatedButton.icon(
            onPressed: () => controller.pickDate(context),
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Obx(() => Text(controller.dateDisplay)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }

  // --- Financial Analysis Card ---
  Widget _buildAnalysisCard(ReportsController controller) {
    return Obx(() {
      Color netColor = controller.netPosition >= 0
          ? Colors.green.shade800
          : Colors.red.shade800;

      return Card(
        margin: const EdgeInsets.all(12),
        elevation: 4,
        // Ensures the ripple effect and background color stay within the rounded corners
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          initiallyExpanded:
              false, // Set to true if you want it open by default
          backgroundColor:
              Colors.brown.shade50, // Slight background tint when expanded
          title: const Text(
            'Period Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          // Shows the most important metric without needing to expand the card!
          subtitle: Text(
            'Net Cash: ₹${controller.netPosition.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: netColor,
              fontSize: 15,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                children: [
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Collected Sales:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₹${controller.totalCollectedSales.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Purchases:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₹${controller.totalPurchases.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weekly Expenses:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₹${controller.totalWeeklyExpenses.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Cash Position:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${controller.netPosition.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: netColor,
                        ),
                      ),
                    ],
                  ),
                  if (controller.salesDifference != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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

  // --- UI Helpers ---
  Widget _buildTabButton(String title, ReportsController controller) {
    bool isActive = controller.activeTab.value == title;
    return InkWell(
      onTap: () => controller.activeTab.value = title,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.brown : Colors.grey.shade300,
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.brown.shade900 : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
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

    // We render ALL tables, even if empty, so you can still record weekly stock balances!
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
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

    // 1. Map Purchase Rows
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
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () => controller.editPurchase(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _confirmDelete(
                  Get.context!,
                  () => controller.deletePurchaseRecord(item.id!),
                ),
              ),
            ],
          ),
        ),
      ]);
      return DataRow(cells: cells);
    }).toList();

    // 2. Calculate Purchase Totals
    double totalQty = data.fold(0.0, (sum, item) => sum + item.quantity);
    double totalWt1 = isBird
        ? data.fold(0.0, (sum, item) => sum + (item.weight1 ?? 0.0))
        : 0.0;
    double totalWt2 = isBird
        ? data.fold(0.0, (sum, item) => sum + (item.weight2 ?? 0.0))
        : 0.0;
    double totalAmt = data.fold(0.0, (sum, item) => sum + item.amount);

    // 3. Append Summary & Interactive Stock Rows

    // ROW A: TOTAL PURCHASES
    List<DataCell> totalCells = [
      const DataCell(
        Text('TOTAL PURCHASES', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataCell(Text('-')),
      DataCell(
        Text(
          totalQty.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    ];
    if (isBird) {
      totalCells.addAll([
        DataCell(
          Text(
            totalWt1.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        DataCell(
          Text(
            totalWt2.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
            fontSize: 15,
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

    // ROW B: OPENING STOCK
    List<DataCell> openCells = [
      DataCell(
        Text(
          '[+] OPENING STOCK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
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

    // ROW C: CLOSING STOCK
    List<DataCell> closeCells = [
      DataCell(
        Text(
          '[-] CLOSING STOCK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          icon: const Icon(Icons.save, size: 16),
          label: const Text('Save Balances'),
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

    // ROW D: ACTUAL CONSUMPTION (Calculated via Obx)
    List<DataCell> actualCells = [
      const DataCell(
        Text(
          '= ACTUAL CONSUMPTION',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        DataCell(
          Obx(
            () => Text(
              '${(totalWt2 + (controller.stockMap['Opening_${title}_Wt2'] ?? 0.0) - (controller.stockMap['Closing_${title}_Wt2'] ?? 0.0)).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

    // 4. Define Columns
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

    // Assemble table
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: themeColor.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '$title Ledger',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                themeColor.withOpacity(0.05),
              ),
              columnSpacing: 20,
              columns: columns,
              rows: rows,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
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
    // Fetch initial value, format to empty string if 0 so it's easier to type
    String currentVal = isInt
        ? (controller.stockMap[mapKey] ?? 0).toString()
        : (controller.stockMap[mapKey] ?? 0.0).toStringAsFixed(2);
    if (currentVal == '0' || currentVal == '0.00') currentVal = '';

    return DataCell(
      SizedBox(
        width: 70,
        child: TextFormField(
          key: ValueKey(
            '${mapKey}_${controller.dateDisplay}',
          ), // Ensures refresh when date changes
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
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            border: OutlineInputBorder(),
            hintText: '0',
          ),
        ),
      ),
    );
  }

  // --- SALES DATATABLE (Remains Unchanged) ---
  Widget _buildSalesTable(List<SaleModel> data) {
    // 1. Map existing data to rows
    List<DataRow> rows = data.map((sale) {
      Color diffColor = sale.difference >= 0
          ? Colors.green.shade700
          : Colors.red.shade700;
      return DataRow(
        cells: [
          DataCell(Text(DateUtil.formatIso(sale.date))),
          DataCell(Text(sale.broilerWt.toStringAsFixed(2))),
          DataCell(Text(sale.muttonWt.toStringAsFixed(2))),
          DataCell(Text(sale.dpWt.toStringAsFixed(2))),
          DataCell(Text(sale.ogWt.toStringAsFixed(2))),
          DataCell(Text(sale.eggQty.toString())),
          DataCell(Text(sale.potaKalejiWt.toStringAsFixed(2))),
          DataCell(Text('₹${sale.sellingAmount.toStringAsFixed(2)}')),
          DataCell(
            Text(
              '₹${sale.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataCell(
            Text(
              '₹${sale.difference.toStringAsFixed(2)}',
              style: TextStyle(color: diffColor, fontWeight: FontWeight.w600),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => Get.find<ReportsController>().editSale(sale),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _confirmDelete(
                    Get.context!,
                    () => Get.find<ReportsController>().deleteSalesRecord(
                      sale.id!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    // 2. Calculate Vertical Column Sums
    double totBroiler = data.fold(0.0, (sum, item) => sum + item.broilerWt);
    double totMutton = data.fold(0.0, (sum, item) => sum + item.muttonWt);
    double totDp = data.fold(0.0, (sum, item) => sum + item.dpWt);
    double totOg = data.fold(0.0, (sum, item) => sum + item.ogWt);
    int totEggs = data.fold(0, (sum, item) => sum + item.eggQty);
    double totPota = data.fold(0.0, (sum, item) => sum + item.potaKalejiWt);
    double totSys = data.fold(0.0, (sum, item) => sum + item.sellingAmount);
    double totCol = data.fold(0.0, (sum, item) => sum + item.totalAmount);
    double totDiff = data.fold(0.0, (sum, item) => sum + item.difference);

    Color finalDiffColor = totDiff >= 0
        ? Colors.green.shade800
        : Colors.red.shade800;

    // 3. Append the Total Row at the bottom
    rows.add(
      DataRow(
        color: MaterialStateProperty.all(Colors.indigo.shade100),
        cells: [
          const DataCell(
            Text(
              'TOTAL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          DataCell(
            Text(
              totBroiler.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              totMutton.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              totDp.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Text(
              totOg.toStringAsFixed(2),
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
              totPota.toStringAsFixed(2),
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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
          columnSpacing: 16,
          columns: const [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Broiler',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Mutton',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'DP Wt',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'OG Wt',
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
                'Pota',
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

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Delete Record',
      middleText:
          'Are you sure? This will permanently delete the record and update the Excel backup.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // close dialog
        onConfirm();
      },
    );
  }

  // --- Trader Payables Card ---
  Widget _buildTraderPayablesCard(ReportsController controller) {
    return Obx(() {
      // Only show the card if there are actual payables to display
      if (controller.traderPayables.isEmpty) {
        return const SizedBox.shrink();
      }
      double grandTotal = controller.traderPayables.values.fold(
        0.0,
        (sum, val) => sum + val,
      );

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          initiallyExpanded: false,
          backgroundColor: Colors.indigo.shade50,
          collapsedBackgroundColor: Colors.white,
          title: const Text(
            'Amount Payable to Traders',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          subtitle: Text(
            'Grand Total: ₹${grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 15,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                children: controller.traderPayables.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry
                              .key, // This will be 'Golden', 'Arif', 'Eggs', etc.
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
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
        margin: const EdgeInsets.all(12),
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          initiallyExpanded: false,
          backgroundColor: Colors.indigo.shade50,
          collapsedBackgroundColor: Colors.white,
          title: const Text(
            'Weekly Bird\'s Eye View (kg)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- HEADER ROW ---
                  const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Item',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Purchase',
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
                          'Diff',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  // --- DATA ROWS ---
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

  Widget _buildBirdRow(String label, Map<String, double> values) {
    Color diffColor = values['Difference']! >= 0 ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
              values['Difference']!.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: TextStyle(color: diffColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
 // --- EXPENSES DATATABLE ---
  Widget _buildExpensesTable(List<ExpenseModel> data) {
    // 1. Map rows
    List<DataRow> rows = data.map((expense) {
      return DataRow(
        cells: [
          DataCell(Text(DateUtil.formatIso(expense.date))),
          DataCell(Text(expense.category, style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(expense.notes.isNotEmpty ? expense.notes : '-')),
          DataCell(
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => Get.find<ReportsController>().editExpense(expense),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _confirmDelete(
                    Get.context!,
                    () => Get.find<ReportsController>().deleteExpenseRecord(expense.id!),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    // 2. Calculate Total
    double totalAmt = data.fold(0.0, (sum, item) => sum + item.amount);

    // 3. Append Total Row
    rows.add(
      DataRow(
        color: MaterialStateProperty.all(Colors.orange.shade50),
        cells: [
          const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
          DataCell(
            Text(
              '₹${totalAmt.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade900),
            ),
          ),
          const DataCell(Text('-')),
        ],
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.orange.shade100),
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Notes', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: rows,
      ),
    );
  }
}
