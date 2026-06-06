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
              'Enter Sold Quantities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // --- Dynamically Calculating Fields ---
            _buildWeightField(
              'Broiler Weight (kg)',
              controller.broilerWt,
              controller.rateBroiler,
            ),
            _buildWeightField(
              'Mutton Weight (kg)',
              controller.muttonWt,
              controller.rateMutton,
            ),
            _buildWeightField(
              'Desi DP Weight (kg)',
              controller.dpWt,
              controller.rateDP,
            ),
            _buildWeightField(
              'Desi OG Weight (kg)',
              controller.ogWt,
              controller.rateOG,
            ),
            _buildWeightField(
              'Pota Kalegi Weight (kg)',
              controller.potaKalejiWt,
              controller.ratePotaKaleji,
            ),

            // Eggs use integers (pieces) and divide by 12 for the dozen rate
            _buildEggField(
              'Egg Quantity (Pieces)',
              controller.eggQty,
              controller.rateEggsDozen,
            ),

            const SizedBox(height: 10),
            const Text(
              'Reconciliation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Manual Total Entry
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
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

            // Live Calculation Output
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
                        color: Colors.black87,
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
                Get.back(); // Return to shop home
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

  Widget _buildWeightField(String label, RxDouble weightObs, RxDouble rateObs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) => weightObs.value = double.tryParse(val) ?? 0.0,
          ),
          const SizedBox(height: 4),

          // The line-item calculation wrapped in Obx
          Obx(() {
            double total = weightObs.value * rateObs.value;
            // Only show the text if the total is greater than 0
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

  Widget _buildEggField(String label, RxInt qtyObs, RxDouble rateObs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => qtyObs.value = int.tryParse(val) ?? 0,
          ),
          const SizedBox(height: 4),

          // The Egg-specific calculation (divided by 12 for dozen rate)
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
}
