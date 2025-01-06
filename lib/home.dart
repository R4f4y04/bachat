import 'package:flutter/material.dart';
import 'package:giki_expense/AddDayPage.dart';
import 'package:giki_expense/EditExpensePage.dart';
import 'package:giki_expense/addExpenseDialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/month_record.dart';
import 'data.dart';
import 'screens/history_screen.dart';
import 'screens/new_month_screen.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Box<MonthRecord> monthsBox;
  MonthRecord? currentMonth;
  double monthlySpent = 0;

  @override
  void initState() {
    super.initState();
    monthsBox = Hive.box<MonthRecord>('months');
    _loadCurrentMonth();
  }

  void _loadCurrentMonth() {
    if (monthsBox.isNotEmpty) {
      currentMonth = monthsBox.values.last;
      _calculateMonthlySpent();
    } else {
      // No months exist, navigate to new month screen
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewMonthScreen()),
        );
      });
    }
  }

  void _calculateMonthlySpent() {
    if (currentMonth != null) {
      monthlySpent = currentMonth!.totalSpent;
    }
  }

  Future<void> _saveMonth() async {
    if (currentMonth != null) {
      currentMonth!.endDate = DateTime.now();
      await monthsBox.put(currentMonth!.key, currentMonth!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Month saved successfully')),
      );
    }
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    if (currentMonth == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(
                themeManager.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeManager.toggleTheme(),
          ),
        ],
        leading: PopupMenuButton(
          color: Theme.of(context).appBarTheme.backgroundColor,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'save',
              child: Text("Save Month"),
            ),
            PopupMenuItem(
              value: 'history',
              child: Text("Expenditure History"),
            ),
          ],
          onSelected: (value) {
            if (value == 'save') {
              _saveMonth();
            } else if (value == 'history') {
              _navigateToHistory();
            }
          },
        ),
        title: Column(
          children: [
            Text(currentMonth!.monthName),
            Text(
              "Spent: ₹${monthlySpent.toStringAsFixed(2)} / ₹${currentMonth!.intendedBudget}",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: monthsBox.listenable(),
        builder: (context, Box<MonthRecord> box, _) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemCount: currentMonth!.days.length,
            itemBuilder: (context, index) {
              final dayRecord = currentMonth!.days[index];
              return DayCard(
                dayRecord: dayRecord,
                index: index,
                onDayUpdated: () {
                  setState(() {
                    _calculateMonthlySpent();
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        onPressed: () => _addNewDay(),
        child: Icon(Icons.add),
        tooltip: 'Add New Day',
      ),
    );
  }

  Future<void> _addNewDay() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDayPage()),
    );

    if (result != null && result is dayexpense) {
      setState(() {
        // Convert dayexpense to DayRecord and add to current month
        final newDayRecord = DayRecord(
          date: DateTime.now().toString(),
          expenses: result.hotels
              .map((p) => ExpenseRecord(
                    name: p.name,
                    amount: p.spent,
                    time: DateTime.now().toString(),
                    items: p.item,
                  ))
              .toList(),
          totalSpent: result.total,
        );
        currentMonth!.days.add(newDayRecord);
        currentMonth!.totalSpent += result.total;
        monthsBox.put(currentMonth!.key, currentMonth!);
      });
    }
  }
}

class DayCard extends StatelessWidget {
  final DayRecord dayRecord;
  final int index;
  final VoidCallback onDayUpdated;

  const DayCard({
    Key? key,
    required this.dayRecord,
    required this.index,
    required this.onDayUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDayPage(index: index),
                  ),
                );
                if (result != null) {
                  onDayUpdated();
                }
              },
              icon: Icons.edit,
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${index + 1}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Total spent: ₹${dayRecord.totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: dayRecord.expenses.length,
                  itemBuilder: (context, i) {
                    final expense = dayRecord.expenses[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                expense.name,
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                expense.time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '₹${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          if (expense.items != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                expense.items!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddExpenseDialog(index: index),
                      ).then((_) => onDayUpdated());
                    },
                    icon: Icon(Icons.add),
                    label: Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      foregroundColor:
                          Theme.of(context).appBarTheme.foregroundColor,
                      minimumSize: Size(120, 36),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
