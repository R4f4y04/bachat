import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/month_record.dart';

class MonthAnalyticsScreen extends StatelessWidget {
  final MonthRecord monthRecord;

  const MonthAnalyticsScreen({super.key, required this.monthRecord});

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
    final maxAmount = monthRecord.days
        .fold(0.0, (max, day) => day.totalSpent > max ? day.totalSpent : max);

    // Calculate nice interval
    final double rawInterval = maxAmount / 5;
    final double magnitude =
        pow(10, (log(rawInterval) / ln10).floor()).toDouble();
    final double niceInterval = (rawInterval / magnitude).ceil() * magnitude;

    String formatAmount(double value) {
      if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
      return value.toInt().toString();
    }

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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: niceInterval,
                    verticalInterval: 5,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < monthRecord.days.length) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text('${value.toInt() + 1}'),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: niceInterval,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              formatAmount(value),
                              style: TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  // ... rest of the chart configuration remains the same
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
    final double totalExpenses =
        categoryTotals.values.fold(0, (sum, amount) => sum + amount);

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                  sections: sortedEntries.asMap().entries.map((entry) {
                    final categoryEntry = entry.value;
                    final percentage = categoryEntry.value / totalExpenses;
                    // Opacity ranges from 1.0 to 0.2 based on percentage
                    final opacity = 0.2 + (percentage * 0.8);

                    return PieChartSectionData(
                      value: categoryEntry.value,
                      title:
                          '${categoryEntry.key}\n${categoryEntry.value.toStringAsFixed(0)}',
                      radius: 100,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                      color: Theme.of(context)
                          .appBarTheme
                          .foregroundColor!
                          .withOpacity(opacity),
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
