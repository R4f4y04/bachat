import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/month_record.dart';

class MonthAnalyticsScreen extends StatelessWidget {
  final MonthRecord monthRecord;

  const MonthAnalyticsScreen({Key? key, required this.monthRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${monthRecord.monthName} Analytics'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDailyExpensesCard(context),
            SizedBox(height: 16),
            _buildExpenseDistributionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyExpensesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Expenses',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthRecord.days.asMap().entries.map((entry) {
                        return FlSpot(
                            entry.key.toDouble(), entry.value.totalSpent);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDistributionCard(BuildContext context) {
    final Map<String, double> categoryTotals = {};
    for (var day in monthRecord.days) {
      for (var expense in day.expenses) {
        categoryTotals.update(
          expense.name,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expense Distribution',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
                      radius: 100,
                      titleStyle: TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
