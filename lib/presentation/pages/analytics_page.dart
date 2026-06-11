import 'package:accounting/core/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Extensive Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildDatePickerCard(context, controller),
                ),
                const SizedBox(height: 20),

                // --- Hero Section: Master KPIs ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionTitle('MASTER FINANCIAL SUMMARY'),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildMasterKPIs(controller),
                ),
                const SizedBox(height: 24),

                // --- NEW: Item-Wise Profitability Breakdown ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionTitle(
                    'ITEM-WISE PROFITABILITY BREAKDOWN',
                  ),
                ),
                const SizedBox(height: 10),
                _buildProfitabilityCards(
                  controller,
                ), // Horizontal Scroll (no horizontal padding needed)
                const SizedBox(height: 24),

                // --- Chart 1: 3-Way Bar Chart ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionTitle('CROSS-SHOP FINANCIAL COMPARISON'),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildBarChartCard(controller),
                ),
                const SizedBox(height: 24),

                // --- Section: Detailed Drill-Down ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionTitle('DETAILED SHOP BREAKDOWNS'),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildShopBreakdownList(controller),
                ),
                const SizedBox(height: 24),

                // --- Chart 2: Categorized Expenses Outlay ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionTitle('EXPENSE DISTRIBUTION'),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildPieChartCard(controller),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey.shade700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDatePickerCard(
    BuildContext context,
    AnalyticsController controller,
  ) {
    DateTime start = controller.selectedDate.value.subtract(
      Duration(days: controller.selectedDate.value.weekday - 1),
    );
    DateTime end = start.add(const Duration(days: 6));
    String displayRange = "${DateUtil.format(start)} - ${DateUtil.format(end)}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Analysis Span:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          ElevatedButton.icon(
            onPressed: () => controller.pickDate(context),
            icon: const Icon(Icons.date_range, size: 16),
            label: Text(displayRange),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade50,
              foregroundColor: Colors.blueGrey.shade900,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterKPIs(AnalyticsController controller) {
    Color netColor = controller.masterNetProfit.value >= 0
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade900],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'MASTER NET CASH POSITION',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${controller.masterNetProfit.value.toStringAsFixed(2)}',
                style: TextStyle(
                  color: netColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniKPI(
                'Total Revenue',
                controller.grandTotalCollected.value,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniKPI(
                'Total Cost (Pur+Exp)',
                controller.grandTotalPurchases.value +
                    controller.grandTotalExpenses.value,
                Colors.orange.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.masterLeakage.value != 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: controller.masterLeakage.value < 0
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: controller.masterLeakage.value < 0
                    ? Colors.red.shade200
                    : Colors.green.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: controller.masterLeakage.value < 0
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cash Difference: ₹${controller.masterLeakage.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: controller.masterLeakage.value < 0
                          ? Colors.red.shade900
                          : Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMiniKPI(String label, double val, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${val.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: Profitability Horizontal Carousel ---
  Widget _buildProfitabilityCards(AnalyticsController controller) {
    if (controller.itemMargins.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'No purchase data recorded for this week to calculate margins.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.itemMargins.length,
        itemBuilder: (context, index) {
          final item = controller.itemMargins[index];
          Color marginColor = item.grossMargin >= 0
              ? Colors.green.shade700
              : Colors.red.shade700;

          IconData icon = Icons.set_meal_outlined;
          if (item.itemName == 'Eggs') icon = Icons.egg_outlined;
          // --- UPDATED: Map DP and OG to the Bird Icon ---
          if (item.itemName == 'Broiler' ||
              item.itemName == 'DP' ||
              item.itemName == 'OG') {
            icon = Icons.pets;
          }
          if (item.itemName == 'Mutton') icon = Icons.restaurant_menu;

          // Dynamically set the unit label
          String unitLabel = item.itemName == 'Eggs' ? '/doz' : '/kg';

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Gross Margin',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),

                // Show dynamic unit label here (/doz or /kg)
                Text(
                  '₹${item.grossMargin.toStringAsFixed(1)} $unitLabel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: marginColor,
                  ),
                ),

                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: marginColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.marginPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: marginColor,
                    ),
                  ),
                ),
                const Spacer(),
                const Divider(height: 8),
                Text(
                  'Avg Buy: ₹${item.avgPurchaseRate.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
                Text(
                  'Master Sell: ₹${item.sellingRate.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarChartCard(AnalyticsController controller) {
    var nk = controller.shopPerformances['NK']!;
    var np = controller.shopPerformances['NP']!;
    var pt = controller.shopPerformances['PT']!;

    double maxVal = [
      nk.totalCollected,
      nk.totalPurchases,
      nk.totalExpenses,
      np.totalCollected,
      np.totalPurchases,
      np.totalExpenses,
      pt.totalCollected,
      pt.totalPurchases,
      pt.totalExpenses,
    ].fold(100.0, (max, element) => element > max ? element : max);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Revenue', Colors.teal.shade500),
                const SizedBox(width: 12),
                _buildLegendItem('Purchases', Colors.red.shade400),
                const SizedBox(width: 12),
                _buildLegendItem('Expenses', Colors.orange.shade400),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.2,
                  barGroups: [
                    _make3WayBarGroup(
                      0,
                      nk.totalCollected,
                      nk.totalPurchases,
                      nk.totalExpenses,
                    ),
                    _make3WayBarGroup(
                      1,
                      np.totalCollected,
                      np.totalPurchases,
                      np.totalExpenses,
                    ),
                    _make3WayBarGroup(
                      2,
                      pt.totalCollected,
                      pt.totalPurchases,
                      pt.totalExpenses,
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['Shop NK', 'Shop NP', 'Shop PT'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopBreakdownList(AnalyticsController controller) {
    return Column(
      children: controller.shopPerformances.values.map((shop) {
        Color netColor = shop.netProfit >= 0
            ? Colors.green.shade700
            : Colors.red.shade700;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SHOP ${shop.shopCode}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Revenue (Collected):',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    '₹${shop.totalCollected.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Purchases COGS:',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    '- ₹${shop.totalPurchases.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Operational Expenses:',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    '- ₹${shop.totalExpenses.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net Profit:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '₹${shop.netProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: netColor,
                    ),
                  ),
                ],
              ),
              if (shop.leakage != 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Difference: ₹${shop.leakage.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: shop.leakage < 0
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChartCard(AnalyticsController controller) {
    if (controller.categoryExpenses.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No expenses logged for this week.')),
        ),
      );
    }

    List<Color> palette = [
      Colors.indigo,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.purple,
      Colors.amber,
      Colors.cyan,
      Colors.brown,
      Colors.pink,
    ];
    int colorIndex = 0;

    List<PieChartSectionData> sections = [];
    List<Widget> legendWidgets = [];

    controller.categoryExpenses.forEach((cat, amt) {
      Color c = palette[colorIndex % palette.length];
      colorIndex++;

      double percentage = (amt / controller.grandTotalExpenses.value) * 100;

      sections.add(
        PieChartSectionData(
          color: c,
          value: amt,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      legendWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${amt.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Total Network OPEX: ₹${controller.grandTotalExpenses.value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendWidgets,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color col) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: col,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  BarChartGroupData _make3WayBarGroup(
    int x,
    double revenue,
    double purchases,
    double expenses,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: revenue,
          color: Colors.teal.shade500,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: purchases,
          color: Colors.red.shade400,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: expenses,
          color: Colors.orange.shade400,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
      barsSpace: 4,
    );
  }
}
