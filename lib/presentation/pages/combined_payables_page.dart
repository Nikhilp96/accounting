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
        title: const Text('Combined Trader Payables'),
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
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.blueGrey),
                  onPressed: () =>
                      _showPaymentHistory(context, controller, summary),
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
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${summary.displayName} - Payment History',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }
}
