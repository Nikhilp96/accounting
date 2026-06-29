// lib/presentation/pages/stock_movement_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/date_util.dart';
import '../controllers/stock_movement_controller.dart';

class StockMovementPage extends StatelessWidget {
  const StockMovementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StockMovementController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Stock Movement - ${controller.shopCode}'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // Date Picker Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      border: Border.all(color: Colors.purple.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: ${DateUtil.format(controller.date.value)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                        ),
                        Icon(Icons.calendar_month, color: Colors.purple.shade800),
                      ],
                    ),
                  ),
                ),
              ),
        
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    String cat = controller.categories[index];
                    bool isPotaOrEgg = cat == 'Pota Kalegi' || cat == 'Egg';
                    return _buildCategoryCard(controller, cat, isPotaOrEgg);
                  },
                ),
              ),
        
              // Save Button
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: controller.saveMovementLog,
                  child: const Text(
                    'Save Stock Movement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryCard(
    StockMovementController ctrl,
    String cat,
    bool noWeight,
  ) {
    var data = ctrl.movementMap[cat]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              cat,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
            const Divider(),

            // Opening & Closing
            _buildRow(
              'Opening Stock (Yest. Close)',
              data.openQty,
              noWeight ? null : data.openWt,
              readOnly: true,
            ),
            _buildRow(
              'Closing Stock (Today Unsold)',
              data.closeQty,
              noWeight ? null : data.closeWt,
            ),

            const SizedBox(height: 12),
            Text(
              'Sent Transfers (Out)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            _buildRow(
              'Sent to ${ctrl.otherShops[0]}',
              data.sendS1Qty,
              noWeight ? null : data.sendS1Wt,
            ),
            if (ctrl.otherShops.length > 1)
              _buildRow(
                'Sent to ${ctrl.otherShops[1]}',
                data.sendS2Qty,
                noWeight ? null : data.sendS2Wt,
              ),

            const SizedBox(height: 12),
            Text(
              'Received Transfers (In)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            _buildRow(
              'Recv from ${ctrl.otherShops[0]}',
              data.recvS1Qty,
              noWeight ? null : data.recvS1Wt,
            ),
            if (ctrl.otherShops.length > 1)
              _buildRow(
                'Recv from ${ctrl.otherShops[1]}',
                data.recvS2Qty,
                noWeight ? null : data.recvS2Wt,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    RxDouble qty,
    RxDouble? wt, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 2, child: _textField('Pcs', qty, readOnly)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: wt != null
                ? _textField('Kg', wt, readOnly)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _textField(String hint, RxDouble obsValue, bool readOnly) {
    return TextFormField(
      initialValue: obsValue.value == 0 ? '' : obsValue.value.toString(),
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) => obsValue.value = double.tryParse(v) ?? 0.0,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
