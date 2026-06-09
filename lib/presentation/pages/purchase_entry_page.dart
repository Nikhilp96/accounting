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
    final bool isEdit = controller.editData != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Modern soft background
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Purchase' : 'New Purchase',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Info ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'SHOP ${controller.shopCode.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // --- Context Card (Date & Category) ---
              _buildCard(
                child: Column(
                  children: [
                    // Date Picker
                    InkWell(
                      onTap: () => controller.pickDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          border: Border.all(color: Colors.teal.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: Colors.teal.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Obx(
                                  () => Text(
                                    DateUtil.format(controller.date.value),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.edit_calendar,
                              color: Colors.teal.shade700,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Item Category Selector
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedItemType.value,
                        decoration: _inputDecoration(
                          'Item Category',
                          Icons.category_outlined,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.teal.shade700,
                        ),
                        items: ['Broiler', 'Desi', 'Eggs', 'Pota Kalegi']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            controller.selectedItemType.value = val;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Details Card (Qty, Rate, Weights, Trader) ---
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENTRY DETAILS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Base Inputs (Always Visible)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.quantityController,
                            decoration: _inputDecoration(
                              'Quantity',
                              Icons.numbers,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            // Safe fallback in case quantity is RxInt or RxDouble
                            onChanged: (val) => controller.quantity.value =
                                double.tryParse(val) ?? 0.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: controller.rateController,
                            decoration: _inputDecoration(
                              'Rate (₹)',
                              Icons.currency_rupee,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (val) => controller.rate.value =
                                double.tryParse(val) ?? 0.0,
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
                                    decoration:
                                        _inputDecoration(
                                          type == 'Broiler'
                                              ? 'Small Wt (kg)'
                                              : 'DP Wt (kg)',
                                          Icons.scale_outlined,
                                        ).copyWith(
                                          filled: true,
                                          fillColor:
                                              controller.weight2.value > 0
                                              ? Colors.grey.shade100
                                              : Colors.white,
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
                                    decoration:
                                        _inputDecoration(
                                          type == 'Broiler'
                                              ? 'Big Wt (kg)'
                                              : 'OG Wt (kg)',
                                          Icons.scale_outlined,
                                        ).copyWith(
                                          filled: true,
                                          fillColor:
                                              controller.weight1.value > 0
                                              ? Colors.grey.shade100
                                              : Colors.white,
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
                            decoration: _inputDecoration(
                              isBird
                                  ? 'Select Trader *'
                                  : 'Select Trader (Optional)',
                              Icons.storefront_outlined,
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.teal.shade700,
                            ),
                            items: controller.availableTraders.map((
                              TraderModel trader,
                            ) {
                              return DropdownMenuItem<int>(
                                value: trader.id,
                                child: Text(
                                  trader.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                controller.selectedTraderId.value = val,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Summary & Save Section ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade500, Colors.teal.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        '₹${controller.calculatedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.teal.shade800,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.savePurchase,
                child: Text(
                  isEdit ? 'Update Purchase Entry' : 'Save Purchase Entry',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.teal.shade600, size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
      ),
    );
  }
}
