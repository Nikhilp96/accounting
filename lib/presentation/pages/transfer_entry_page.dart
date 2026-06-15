import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transfer_entry_controller.dart';

class TransferEntryPage extends StatelessWidget {
  const TransferEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Delete stale instance if exists, then create fresh
    Get.delete<TransferEntryController>(force: true);
    final controller = Get.put(TransferEntryController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          controller.isEditing
              ? 'Edit Stock Transfer'
              : 'Inter-Shop Stock Transfer',
        ),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => controller.pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(
                              () => Text(
                                'Date: ${DateUtil.format(controller.date.value)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade900,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month,
                              color: Colors.teal.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- DYNAMIC FROM/TO SHOPS & SWAP ---
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.fromShop.value,
                              decoration: const InputDecoration(
                                labelText: 'Transfer FROM',
                                border: OutlineInputBorder(),
                              ),
                              items: controller.shops
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  controller.updateFromShop(val!),
                            ),
                          ),
                        ),

                        // New interactive swap button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.swap_horiz,
                              color: Colors.teal.shade700,
                              size: 28,
                            ),
                            tooltip: 'Swap Direction',
                            onPressed: controller.swapShops,
                          ),
                        ),

                        Expanded(
                          child: Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.toShop.value,
                              decoration: const InputDecoration(
                                labelText: 'Transfer TO',
                                border: OutlineInputBorder(),
                              ),
                              items: controller.shops
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => controller.updateToShop(val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.itemType.value,
                        decoration: const InputDecoration(
                          labelText: 'Item Type',
                          border: OutlineInputBorder(),
                        ),
                        items: controller.itemTypes
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) => controller.itemType.value = val!,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Obx(() {
                      bool isBroiler = controller.itemType.value == 'Broiler';
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.qtyController,
                              decoration: const InputDecoration(
                                labelText: 'Qty (Pcs)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => controller.qty.value =
                                  double.tryParse(val) ?? 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controller.weight1Controller,
                              decoration: InputDecoration(
                                labelText: isBroiler
                                    ? 'Small Wt (kg)'
                                    : 'Total Wt (kg)',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              // --- UPDATED THIS LINE ---
                              onChanged: controller.onWeight1Changed,
                            ),
                          ),
                          if (isBroiler) const SizedBox(width: 8),
                          if (isBroiler)
                            Expanded(
                              child: TextField(
                                controller: controller.weight2Controller,
                                decoration: const InputDecoration(
                                  labelText: 'Big Wt (kg)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                // --- UPDATED THIS LINE ---
                                onChanged: controller.onWeight2Changed,
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.teal.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: controller.saveTransfer,
                child: Text(
                  controller.isEditing ? 'Update Transfer' : 'Log Transfer',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
