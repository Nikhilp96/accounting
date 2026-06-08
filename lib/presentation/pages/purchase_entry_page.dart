import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/purchase_entry_controller.dart';
import '../../data/models/app_models.dart';

class PurchaseEntryPage extends StatelessWidget {
  const PurchaseEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PurchaseEntryController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Purchase Entry - Shop ${controller.shopCode}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      const Icon(Icons.calendar_today, color: Colors.teal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Item Type Selector
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedItemType.value,
                  decoration: const InputDecoration(
                    labelText: 'Item Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Broiler', 'Desi', 'Eggs', 'Pota Kalegi']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedItemType.value = val;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Base Inputs (Always Visible)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          controller.quantityController, // <-- ADDED THIS
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => controller.quantity.value =
                          double.tryParse(val) ?? 0.0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller.rateController, // <-- ADDED THIS
                      decoration: const InputDecoration(
                        labelText: 'Rate (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) =>
                          controller.rate.value = double.tryParse(val) ?? 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dynamic Inputs based on Item Type
              Obx(() {
                final type = controller.selectedItemType.value;
                final isBird = type == 'Broiler' || type == 'Desi';

                return Column(
                  children: [
                    // Only show Weight rows if it is a Bird
                    if (isBird) ...[
                      Row(
                        children: [
                          // WEIGHT 1
                          Expanded(
                            child: TextField(
                              controller: controller.weight1Controller,
                              decoration: InputDecoration(
                                labelText: type == 'Broiler'
                                    ? 'Small Wt (kg)'
                                    : 'DP Wt (kg)',
                                border: const OutlineInputBorder(),
                                filled: controller.weight2.value > 0,
                                fillColor: controller.weight2.value > 0
                                    ? Colors.grey.shade200
                                    : null,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: controller.onWeight1Changed,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // WEIGHT 2
                          Expanded(
                            child: TextField(
                              controller: controller.weight2Controller,
                              decoration: InputDecoration(
                                labelText: type == 'Broiler'
                                    ? 'Big Wt (kg)'
                                    : 'OG Wt (kg)',
                                border: const OutlineInputBorder(),
                                filled: controller.weight1.value > 0,
                                fillColor: controller.weight1.value > 0
                                    ? Colors.grey.shade200
                                    : null,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: controller.onWeight2Changed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Trader Dropdown (ALWAYS VISIBLE)
                    DropdownButtonFormField<int>(
                      value: controller.selectedTraderId.value,
                      decoration: InputDecoration(
                        // Dynamic Label based on item type
                        labelText: isBird
                            ? 'Select Trader *'
                            : 'Select Trader (Optional)',
                        border: const OutlineInputBorder(),
                      ),
                      items: controller.availableTraders.map((
                        TraderModel trader,
                      ) {
                        return DropdownMenuItem<int>(
                          value: trader.id,
                          child: Text(trader.name),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          controller.selectedTraderId.value = val,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),

              // Live Calculation Output
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal),
                ),
                child: Obx(
                  () => Text(
                    'Total Amount: ₹${controller.calculatedAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  controller.savePurchase();
                  // Get.back();
                },
                child: const Text(
                  'Save Purchase Entry',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
