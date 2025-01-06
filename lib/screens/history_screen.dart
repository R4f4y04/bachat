import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/month_record.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenditure History'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<MonthRecord>('months').listenable(),
        builder: (context, Box<MonthRecord> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text('No history available'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final month = box.getAt(index);
              if (month == null) return SizedBox.shrink();

              final daysCount = month.days.length;
              final completionStatus =
                  month.endDate != null ? 'Completed' : 'In Progress';
              final duration = month.endDate != null
                  ? '${month.startDate.day}/${month.startDate.month} - ${month.endDate!.day}/${month.endDate!.month}'
                  : 'Started ${month.startDate.day}/${month.startDate.month}';

              return Card(
                child: ExpansionTile(
                  title: Text(month.monthName),
                  subtitle: Text(duration),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: $completionStatus'),
                          SizedBox(height: 8),
                          Text('Total Days: $daysCount'),
                          SizedBox(height: 8),
                          Text('Budget: ₹${month.intendedBudget}'),
                          SizedBox(height: 8),
                          Text('Spent: ₹${month.totalSpent}'),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: month.totalSpent / month.intendedBudget,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                                month.totalSpent > month.intendedBudget
                                    ? Colors.red
                                    : Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
