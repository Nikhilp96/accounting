import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_entry_controller.dart';

class SalesEntryPage extends StatelessWidget {
  const SalesEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesEntryController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Sales - Shop ${controller.shopCode}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Date Picker UI ---
            InkWell(
              onTap: () => controller.pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        'Date: ${DateUtil.format(controller.date.value)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.indigo),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Enter Sold Quantities & Rates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // --- Dynamically Calculating Fields ---
            _buildWeightField(
              'Broiler Wt (kg)',
              controller.broilerWt,
              controller.rateBroiler,
              controller.wtBroilerCtrl,
              controller.rateBroilerCtrl,
            ),
            _buildMuttonSection(controller),
            _buildWeightField(
              'Desi DP Wt (kg)',
              controller.dpWt,
              controller.rateDP,
              controller.wtDPCtrl,
              controller.rateDPCtrl,
            ),
            _buildWeightField(
              'Desi OG Wt (kg)',
              controller.ogWt,
              controller.rateOG,
              controller.wtOGCtrl,
              controller.rateOGCtrl,
            ),
            _buildWeightField(
              'Pota Kalegi Wt (kg)',
              controller.potaKalejiWt,
              controller.ratePotaKaleji,
              controller.wtPotaCtrl,
              controller.ratePotaCtrl,
            ),

            _buildEggField(
              'Eggs (Pieces)',
              controller.eggQty,
              controller.rateEggsDozen,
              controller.qtyEggsCtrl,
              controller.rateEggsCtrl,
            ),

            const SizedBox(height: 10),
            const Text(
              'Reconciliation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: controller.totalAmountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Total Amount Collected (₹)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.yellowAccent,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (val) => controller.userTotalAmount.value =
                    double.tryParse(val) ?? 0.0,
              ),
            ),

            Obx(() {
              double diff = controller.differenceAmount;
              Color diffColor = diff >= 0
                  ? Colors.green.shade700
                  : Colors.red.shade700;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo),
                ),
                child: Column(
                  children: [
                    Text(
                      'System Selling Amount: ₹${controller.calculatedSellingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Difference: ₹${diff.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: diffColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                controller.saveWeeklySale();
                Get.back();
              },
              child: const Text(
                'Save Weekly Sales',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildWeightField(
    String label,
    RxDouble weightObs,
    RxDouble rateObs,
    TextEditingController wtCtrl,
    TextEditingController rateCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: wtCtrl,
                  decoration: InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) =>
                      weightObs.value = double.tryParse(val) ?? 0.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: rateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Rate (₹)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) =>
                      rateObs.value = double.tryParse(val) ?? 0.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() {
            double total = weightObs.value * rateObs.value;
            if (total == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Item Total: ₹${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEggField(
    String label,
    RxInt qtyObs,
    RxDouble rateObs,
    TextEditingController qtyCtrl,
    TextEditingController rateCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: qtyCtrl,
                  decoration: InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => qtyObs.value = int.tryParse(val) ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: rateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Rate/Doz',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) =>
                      rateObs.value = double.tryParse(val) ?? 0.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() {
            double total = (qtyObs.value / 12) * rateObs.value;
            if (total == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Item Total: ₹${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMuttonSection(SalesEntryController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mutton Calculation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Row 1: Stock Balances
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.wtMuttonOpeningCtrl,
                  decoration: const InputDecoration(
                    labelText: "Yest. Unsold (kg)",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) => controller.muttonOpeningWt.value =
                      double.tryParse(val) ?? 0.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.wtMuttonClosingCtrl,
                  decoration: const InputDecoration(
                    labelText: "Today Unsold (kg)",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) => controller.muttonClosingWt.value =
                      double.tryParse(val) ?? 0.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Raw Weight & Rate
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller.wtMuttonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Raw Mutton Wt (kg)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) =>
                      controller.muttonWt.value = double.tryParse(val) ?? 0.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: controller.rateMuttonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Rate (₹)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) =>
                      controller.rateMutton.value = double.tryParse(val) ?? 0.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Live Formula Output
          Obx(() {
            double billableWt =
                (controller.muttonWt.value / 1.6) +
                controller.muttonOpeningWt.value -
                controller.muttonClosingWt.value;
            if (billableWt < 0) billableWt = 0;
            double total = billableWt * controller.rateMutton.value;

            if (total == 0) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Billable Wt: ${billableWt.toStringAsFixed(2)} kg',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Item Total: ₹${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
