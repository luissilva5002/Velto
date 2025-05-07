import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/google_sheets.dart';
import '../../services/sheets_client.dart';

class Bondora extends StatefulWidget {
  final String spreadsheetId;

  const Bondora({
    super.key,
    required this.spreadsheetId,
  });

  @override
  State<Bondora> createState() => _BondoraPageState();
}

class _BondoraPageState extends State<Bondora> {
  Map<String, String?> bondoraValues = {};
  bool isLoading = true;

  final cellMap = {
    'C31': 'Invested',
    'C17': 'Effective Rate',
    'C34': 'Total',
    'C37': 'Accumulated Interest',
    'C41': 'Daily Interest',
    'C43': 'Monthly Interest',
  };

  @override
  void initState() {
    super.initState();
    loadBondoraData();
  }

  Future<void> loadBondoraData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final client = await getSheetsClient();
      final sheets = GoogleSheetsService(widget.spreadsheetId, client);

      final fetched = <String, String?>{};
      for (final cell in cellMap.keys) {
        final value = await sheets.getCell('Bondora Investments!$cell');
        fetched[cell] = value;
      }

      if (!mounted) return;

      setState(() {
        bondoraValues = fetched;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }


  double _cleanAndConvertToDouble(String? rawValue) {
    if (rawValue == null) return 0.0;

    final cleaned = rawValue
        .replaceAll('€', '')
        .replaceAll('\u202f', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(cleaned) ?? 0.0;
  }

  double getValueOrDefault(String cell) {
    return _cleanAndConvertToDouble(bondoraValues[cell]);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final investedAmount = getValueOrDefault('C31');
    final effectiveRate = getValueOrDefault('C17');
    final totalAmount = getValueOrDefault('C34');
    final accumulatedInterest = getValueOrDefault('C37');
    final dailyInterest = getValueOrDefault('C41');
    final monthlyInterest = getValueOrDefault('C43');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bondora Overview'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: loadBondoraData,
              icon: Icon(Icons.refresh)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top section with 3 main cards
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoCard(
                        title: 'INVESTED',
                        value: '€${investedAmount.toStringAsFixed(2)}',
                        color: Colors.grey.shade100,
                        onView: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        title: 'EFFECTIVE RATE',
                        value: '${effectiveRate.toStringAsFixed(1)}%',
                        color: Colors.grey.shade100,
                        showView: false,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildInfoCard(
                    title: 'TOTAL',
                    value: '€${totalAmount.toStringAsFixed(2)}',
                    color: Colors.green.shade100,
                    showView: true,
                    height: 216,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interest container
            Container(
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('DAILY INTEREST'),
                      Text('€${dailyInterest.toStringAsFixed(2)}'),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('MONTHLY INTEREST'),
                      Text('€${monthlyInterest.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bar chart
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Invested');
                            case 1:
                              return const Text('Interest');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                        toY: investedAmount,
                        width: 20,
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                        toY: accumulatedInterest,
                        width: 20,
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ]),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Bottom total card
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ACCUMULATED INTEREST:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '€${accumulatedInterest.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color color,
    bool showView = true,
    double height = 100,
    VoidCallback? onView,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (showView)
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: onView ?? () {},
                child: const Text(
                  'view →',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
