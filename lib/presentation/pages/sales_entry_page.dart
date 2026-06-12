import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_entry_controller.dart';

class SalesEntryPage extends StatelessWidget {
  const SalesEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesEntryController());
    final bool isEdit = controller.editData != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Modern soft background
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Weekly Sales' : 'Weekly Sales',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade800,
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

              // --- Context Card (Date Picker) ---
              _buildCard(
                child: InkWell(
                  onTap: () => controller.pickDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      border: Border.all(color: Colors.indigo.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: Colors.indigo.shade700,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Obx(
                              () => Text(
                                DateUtil.format(controller.date.value),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.edit_calendar,
                          color: Colors.indigo.shade700,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Poultry & Others Card ---
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'POULTRY & OTHERS',
                      Icons.set_meal_outlined,
                      Colors.indigo,
                    ),
                    const SizedBox(height: 16),
                    _buildWeightField(
                      'Broiler (kg)',
                      controller.broilerQty,
                      controller.broilerWt,
                      controller.rateBroiler,
                      controller.qtyBroilerCtrl,
                      controller.wtBroilerCtrl,
                      controller.rateBroilerCtrl,
                    ),
                    _buildWeightField(
                      'Desi DP (kg)',
                      controller.dpQty,
                      controller.dpWt,
                      controller.rateDP,
                      controller.qtyDPCtrl,
                      controller.wtDPCtrl,
                      controller.rateDPCtrl,
                    ),
                    _buildWeightField(
                      'Desi OG (kg)',
                      controller.ogQty,
                      controller.ogWt,
                      controller.rateOG,
                      controller.qtyOGCtrl,
                      controller.wtOGCtrl,
                      controller.rateOGCtrl,
                    ),
                    _buildWeightField(
                      'Pota Kalegi (kg)',
                      controller.potaKalejiQty,
                      controller.potaKalejiWt,
                      controller.ratePotaKaleji,
                      controller.qtyPotaCtrl,
                      controller.wtPotaCtrl,
                      controller.ratePotaCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Mutton Card ---
              _buildCard(child: _buildMuttonSection(controller)),
              const SizedBox(height: 16),

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'MORTALITY (DEAD BIRDS)',
                      Icons.warning_amber_rounded,
                      Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildMortalityField(
                      'Broiler Dead (kg)',
                      controller.broilerDeadQty,
                      controller.broilerDeadWt,
                      controller.qtyBroilerDeadCtrl,
                      controller.wtBroilerDeadCtrl,
                    ),
                    _buildMortalityField(
                      'DP Dead (kg)',
                      controller.dpDeadQty,
                      controller.dpDeadWt,
                      controller.qtyDPDeadCtrl,
                      controller.wtDPDeadCtrl,
                    ),
                    _buildMortalityField(
                      'OG Dead (kg)',
                      controller.ogDeadQty,
                      controller.ogDeadWt,
                      controller.qtyOGDeadCtrl,
                      controller.wtOGDeadCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Eggs Card ---
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'EGG SALES',
                      Icons.egg_outlined,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildEggField(
                      'Eggs (Pieces)',
                      controller.eggQty,
                      controller.rateEggsDozen,
                      controller.qtyEggsCtrl,
                      controller.rateEggsCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Reconciliation Card (Hero Section) ---
              Container(
                padding: const EdgeInsets.all(24),
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
                  border: Border.all(color: Colors.indigo.shade100, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(
                      'RECONCILIATION',
                      Icons.account_balance_wallet_outlined,
                      Colors.indigo,
                    ),
                    const SizedBox(height: 20),

                    // User Input for Total Collected
                    TextField(
                      controller: controller.totalAmountCtrl,
                      decoration: InputDecoration(
                        labelText: 'Total Cash Collected (₹)',
                        labelStyle: TextStyle(
                          color: Colors.indigo.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                          color: Colors.indigo.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.indigo.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.indigo.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.indigo.shade900,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => controller.userTotalAmount.value =
                          double.tryParse(val) ?? 0.0,
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Difference Output
                    Obx(() {
                      double diff = controller.differenceAmount;
                      Color diffColor = diff >= 0
                          ? Colors.green.shade600
                          : Colors.red.shade600;
                      IconData diffIcon = diff >= 0
                          ? Icons.trending_up
                          : Icons.trending_down;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: diffColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: diffColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'System Calculated:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '₹${controller.calculatedSellingAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Difference:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '₹${diff.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: diffColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(diffIcon, color: diffColor),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Save Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.indigo.shade800,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  controller.saveWeeklySale();
                  // Back navigation is handled in the controller to ensure it waits for backup
                },
                child: Text(
                  isEdit ? 'Update Weekly Sales' : 'Save Weekly Sales',
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, MaterialColor color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color.shade800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
      ),
    );
  }

  // --- Dynamic Field Builders ---

  Widget _buildWeightField(
    String label,
    RxInt qtyObs,
    RxDouble weightObs,
    RxDouble rateObs,
    TextEditingController qtyCtrl,
    TextEditingController wtCtrl,
    TextEditingController rateCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: qtyCtrl,
                  decoration: _inputDecoration('Qty'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => qtyObs.value = int.tryParse(val) ?? 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: wtCtrl,
                  decoration: _inputDecoration(label),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) =>
                      weightObs.value = double.tryParse(val) ?? 0.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: rateCtrl,
                  decoration: _inputDecoration('Rate (₹)'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) =>
                      rateObs.value = double.tryParse(val) ?? 0.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Obx(() {
            double total = weightObs.value * rateObs.value;
            if (total == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Item Total: ₹${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: TextField(
                controller: qtyCtrl,
                decoration: _inputDecoration(label),
                keyboardType: TextInputType.number,
                onChanged: (val) => qtyObs.value = int.tryParse(val) ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: TextField(
                controller: rateCtrl,
                decoration: _inputDecoration('Rate / Doz'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (val) => rateObs.value = double.tryParse(val) ?? 0.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Obx(() {
          double total = (qtyObs.value / 12) * rateObs.value;
          if (total == 0) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              'Item Total: ₹${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMuttonSection(SalesEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('MUTTON SALES', Icons.restaurant_menu, Colors.red),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Column(
            children: [
              // Row 1: Stock Balances
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.wtMuttonOpeningCtrl,
                      decoration: _inputDecoration("Yest. Unsold (kg)"),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => controller.muttonOpeningWt.value =
                          double.tryParse(val) ?? 0.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller.wtMuttonClosingCtrl,
                      decoration: _inputDecoration("Today Unsold (kg)"),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => controller.muttonClosingWt.value =
                          double.tryParse(val) ?? 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: Raw Qty, Weight & Rate
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controller.qtyMuttonCtrl,
                      decoration: _inputDecoration('Qty'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) =>
                          controller.muttonQty.value = int.tryParse(val) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: controller.wtMuttonCtrl,
                      decoration: _inputDecoration('Raw (kg)'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => controller.muttonWt.value =
                          double.tryParse(val) ?? 0.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: controller.rateMuttonCtrl,
                      decoration: _inputDecoration('Rate (₹)'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => controller.rateMutton.value =
                          double.tryParse(val) ?? 0.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Live Formula Output
        Obx(() {
          double billableWt =
              (controller.muttonWt.value / 1.6) +
              controller.muttonOpeningWt.value -
              controller.muttonClosingWt.value;
          if (billableWt < 0) billableWt = 0;
          double total = billableWt * controller.rateMutton.value;

          if (total == 0) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Billable: ${billableWt.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
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
            ),
          );
        }),
      ],
    );
  }

  // Add the _buildMortalityField UI Helper at the bottom of the file:
  Widget _buildMortalityField(
    String label,
    RxInt qtyObs,
    RxDouble weightObs,
    TextEditingController qtyCtrl,
    TextEditingController wtCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: qtyCtrl,
              decoration: _inputDecoration('Dead Qty'),
              keyboardType: TextInputType.number,
              onChanged: (val) => qtyObs.value = int.tryParse(val) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: TextField(
              controller: wtCtrl,
              decoration: _inputDecoration(label),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (val) => weightObs.value = double.tryParse(val) ?? 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
