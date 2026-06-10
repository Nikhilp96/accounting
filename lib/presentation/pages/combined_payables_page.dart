import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/combined_payables_controller.dart';
import '../../data/models/app_models.dart';

class CombinedPayablesPage extends StatelessWidget {
  const CombinedPayablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CombinedPayablesController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Combined Trader Payables',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Billing Week:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.pickDate(context),
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Obx(() => Text(controller.dateDisplay)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade50,
                      foregroundColor: Colors.indigo.shade900,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Ledger List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.payableSummaries.isEmpty) {
                  return const Center(
                    child: Text('No purchases recorded yet.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: controller.payableSummaries.length,
                  itemBuilder: (context, index) {
                    final summary = controller.payableSummaries[index];
                    return _buildTraderCard(context, controller, summary);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraderCard(
    BuildContext context,
    CombinedPayablesController controller,
    PayableSummary summary,
  ) {
    Color balanceColor = summary.outstanding > 0
        ? Colors.red.shade700
        : Colors.green.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  summary.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.indigo,
                      ),
                      tooltip: 'View Purchases History',
                      onPressed: () =>
                          _showPurchaseHistory(context, controller, summary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.blueGrey),
                      tooltip: 'View Payment History',
                      onPressed: () =>
                          _showPaymentHistory(context, controller, summary),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),

            // Contextual Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Billing for Selected Week:',
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  '₹${summary.periodPurchases.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Core Metric
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: balanceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Outstanding Balance:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '₹${summary.outstanding.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: balanceColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action
            ElevatedButton.icon(
              onPressed: () =>
                  _showAddPaymentDialog(context, controller, summary),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Log Payment / Enter Balance Paid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CROSS-SHOP PURCHASE HISTORY BOTTOM SHEET ---
  void _showPurchaseHistory(
    BuildContext context,
    CombinedPayablesController controller,
    PayableSummary summary,
  ) {
    // 1. Calculate boundaries of the Currently Selected Week
    DateTime selected = controller.selectedDate.value;
    DateTime startOfWeek = selected.subtract(
      Duration(days: selected.weekday - 1),
    );
    DateTime start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
      0,
      0,
      0,
    );
    DateTime end = start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    // 2. Filter purchases targeting this trader AND within the selected week
    final history = controller.allPurchases.where((p) {
      bool matchesTrader =
          p.traderId == summary.traderId && p.itemType == summary.itemType;
      if (!matchesTrader) return false;

      DateTime pDate = DateTime.parse(p.date);
      return pDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          pDate.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    Get.bottomSheet(
      Container(
        // Cap the height to 75% of the screen so the Expanded list doesn't cause overflow errors
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          // <-- Added SafeArea here
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${summary.displayName} - Week Purchases',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    Text(
                      'Items: ${history.length}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                if (history.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No purchases recorded during this week.'),
                    ),
                  ),
                if (history.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (ctx, i) {
                        var purchase = history[i];
                        bool isBird =
                            purchase.itemType == 'Broiler' ||
                            purchase.itemType == 'Desi';
                        double weightDisplay =
                            (purchase.weight1 ?? 0.0) +
                            (purchase.weight2 ?? 0.0);

                        // Color code individual shop labels
                        Color shopBg = purchase.shopCode == 'NK'
                            ? Colors.blueGrey.shade100
                            : purchase.shopCode == 'NP'
                            ? Colors.teal.shade100
                            : Colors.indigo.shade100;
                        Color shopText = purchase.shopCode == 'NK'
                            ? Colors.blueGrey.shade900
                            : purchase.shopCode == 'NP'
                            ? Colors.teal.shade900
                            : Colors.indigo.shade900;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              // Shop Badge Indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: shopBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  purchase.shopCode,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: shopText,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Details Columns
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateUtil.formatIso(purchase.date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isBird
                                          ? 'Qty: ${purchase.quantity.toStringAsFixed(0)} • Wt: ${weightDisplay.toStringAsFixed(2)} kg'
                                          : 'Qty: ${purchase.quantity.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Rate: ₹${purchase.rate.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Cost Total Right side aligned
                              Text(
                                '₹${purchase.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddPaymentDialog(
    BuildContext context,
    CombinedPayablesController controller,
    PayableSummary summary,
  ) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime payDate = DateTime.now();

    Get.dialog(
      AlertDialog(
        title: Text('Pay ${summary.displayName}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current Outstanding: ₹${summary.outstanding.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: payDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => payDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date: ${DateUtil.format(payDate)}'),
                          const Icon(Icons.calendar_month),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount Paid (₹)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Bank / Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              double amt = double.tryParse(amountController.text) ?? 0;
              if (amt > 0) {
                controller.savePayment(
                  summary,
                  amt,
                  payDate.toIso8601String(),
                  notesController.text,
                );
                Get.back();
              }
            },
            child: const Text(
              'Save Payment',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentHistory(
    BuildContext context,
    CombinedPayablesController controller,
    PayableSummary summary,
  ) {
    final history = controller.allPayments
        .where(
          (p) =>
              p.traderId == summary.traderId && p.itemType == summary.itemType,
        )
        .toList();

    Get.bottomSheet(
      Container(
        // Applied identical safe height limits to the Payment sheet
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          // <-- Added SafeArea here
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${summary.displayName} - Payment History',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                if (history.isEmpty)
                  const Expanded(
                    child: Center(child: Text('No payments recorded.')),
                  ),
                if (history.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (ctx, i) {
                        var pay = history[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(Icons.check, color: Colors.green),
                          ),
                          title: Text(
                            '₹${pay.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${DateUtil.formatIso(pay.date)} • ${pay.notes}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Get.back();
                              controller.deletePayment(pay.id!);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
