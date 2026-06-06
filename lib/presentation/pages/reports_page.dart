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
      appBar: AppBar(
        title: Text('Reports - Shop ${controller.shopCode}'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildControlHeader(context, controller),
          _buildAnalysisCard(controller),

          // Tab Toggle
          Obx(
            () => Row(
              children: [
                Expanded(child: _buildTabButton('Purchases', controller)),
                Expanded(child: _buildTabButton('Sales', controller)),
              ],
            ),
          ),

          // Data Table
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value)
                return const Center(child: CircularProgressIndicator());

              if (controller.activeTab.value == 'Purchases') {
                if (controller.purchasesList.isEmpty)
                  return const Center(
                    child: Text('No purchases in this period.'),
                  );
                return _buildPurchasesTable(controller.purchasesList);
              } else {
                if (controller.salesList.isEmpty)
                  return const Center(child: Text('No sales in this period.'));
                return _buildSalesTable(controller.salesList);
              }
            }),
          ),
        ],
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Period Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const Divider(),
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
                    'Total Collected Sales:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${controller.totalCollectedSales.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net Cash Position:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // --- PURCHASES DATATABLE ---
  Widget _buildPurchasesTable(List<PurchaseModel> data) {
    // Reference the controller to access the trader map
    final controller = Get.find<ReportsController>();

    // 1. Map existing data to rows
    List<DataRow> rows = data.map((item) {
      // Lookup the trader name using the ID. Fallback to '-' if null or not found (like for Eggs)
      String traderName = item.traderId != null
          ? controller.traderMap[item.traderId] ?? '-'
          : '-';

      return DataRow(
        cells: [
          DataCell(Text(DateUtil.formatIso(item.date))),
          DataCell(Text(item.itemType)),
          DataCell(Text(traderName)), // <-- NEW: Trader Name Cell
          DataCell(Text(item.quantity.toString())),
          DataCell(Text(item.weight1?.toStringAsFixed(2) ?? '-')),
          DataCell(Text(item.weight2?.toStringAsFixed(2) ?? '-')),
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
        ],
      );
    }).toList();

    // 2. Calculate Vertical Column Sums
    int totalQty = data.fold(0, (sum, item) => sum + item.quantity);
    double totalWt1 = data.fold(
      0.0,
      (sum, item) => sum + (item.weight1 ?? 0.0),
    );
    double totalWt2 = data.fold(
      0.0,
      (sum, item) => sum + (item.weight2 ?? 0.0),
    );
    double totalAmt = data.fold(0.0, (sum, item) => sum + item.amount);

    // 3. Append the Total Row at the bottom (Now requires 9 cells)
    rows.add(
      DataRow(
        color: MaterialStateProperty.all(Colors.teal.shade100),
        cells: [
          const DataCell(
            Text(
              'TOTAL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const DataCell(Text('-')), // Item
          const DataCell(Text('-')), // <-- NEW: Empty cell for Trader Column
          DataCell(
            Text(
              totalQty.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          DataCell(
            Text(
              totalWt1.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          DataCell(
            Text(
              totalWt2.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const DataCell(Text('-')), // Rate
          DataCell(
            Text(
              '₹${totalAmt.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.teal,
              ),
            ),
          ),
          const DataCell(Text('-')), // Action
        ],
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
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
                'Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Trader',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ), // <-- NEW: Trader Column Header
            DataColumn(
              label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text(
                'Small/DP Wt',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Big/OG Wt',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Rate',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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

  // --- SALES DATATABLE ---
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
          // CORRECTED: Added Action Cell (11th cell)
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
          const DataCell(Text('-')), // CORRECTED: Added empty 11th cell
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
            ), // CORRECTED: Added 11th Column
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
}
