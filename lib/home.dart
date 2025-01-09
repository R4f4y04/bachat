import 'package:flutter/material.dart';
import 'package:giki_expense/AddDayPage.dart';
import 'package:giki_expense/EditExpensePage.dart';
import 'package:giki_expense/addExpenseDialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:giki_expense/utilities/util_functions.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/month_record.dart';
import 'utilities/data.dart';
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
  List<bool> expandedStates = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    monthsBox = Hive.box<MonthRecord>('months');
    _loadCurrentMonth();
  }

  Future<void> _addNewDay() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDayPage()),
    );

    if (result != null && result is dayexpense) {
      setState(() {
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
        expandedStates.add(false);

        // Save to Hive
        monthsBox.put(currentMonth!.key, currentMonth!);
        _calculateMonthlySpent();
      });
    }
  }

  void _addExpenseToDay(int dayIndex, ExpenseRecord newExpense) {
    setState(() {
      currentMonth!.days[dayIndex].expenses.add(newExpense);
      currentMonth!.days[dayIndex].totalSpent += newExpense.amount;
      currentMonth!.totalSpent += newExpense.amount;
      monthsBox.put(currentMonth!.key, currentMonth!);
      _calculateMonthlySpent();
    });
  }

  void _deleteDay(int index) {
    setState(() {
      // Subtract the day's total from monthly total
      currentMonth!.totalSpent -= currentMonth!.days[index].totalSpent;

      // Remove the day
      currentMonth!.days.removeAt(index);
      expandedStates.removeAt(index);

      // Save to Hive
      monthsBox.put(currentMonth!.key, currentMonth!);
      _calculateMonthlySpent();
    });
  }

  void _loadCurrentMonth() {
    if (monthsBox.isNotEmpty) {
      setState(() {
        currentMonth = monthsBox.values.last;
        expandedStates =
            List.generate(currentMonth?.days.length ?? 0, (_) => false);
        _calculateMonthlySpent(); // Add this line
      });
    } else {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewMonthScreen()),
      );
    }
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryScreen()),
    );
  }

  Future<void> _handleRefresh() async {
    try {
      // Show loading state
      setState(() {
        isLoading = true;
      });

      // Add minimal delay for smooth animation
      await Future.delayed(Duration(milliseconds: 800));

      // Reload current month
      _loadCurrentMonth();

      // Recalculate monthly spent
      if (currentMonth != null) {
        double newMonthlySpent = 0;
        for (var day in currentMonth!.days) {
          newMonthlySpent += day.totalSpent;
        }

        // Update state
        setState(() {
          monthlySpent = newMonthlySpent;
          currentMonth!.totalSpent = newMonthlySpent;
          isLoading = false;
        });

        // Save updated month
        await monthsBox.put(currentMonth!.key, currentMonth!);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refreshed successfully')),
        );
      }
    } catch (e) {
      // Handle any errors
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing: $e')),
      );
    }
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
              "Spent: Rs. ${monthlySpent.toStringAsFixed(2)} / Rs. ${currentMonth!.intendedBudget}",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: LiquidPullToRefresh(
        onRefresh: () async {
          // Implement refresh logic
          await Future.delayed(Duration(
              milliseconds: 700)); // Minimal delay for smooth animation
          setState(() {
            _loadCurrentMonth();
          });
        },
        showChildOpacityTransition: false, // Nice fade effect while refreshing
        color: Theme.of(context).cardColor, // Match app theme
        height: 80, // Pull distance
        animSpeedFactor: 2, // Animation speed
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: ValueListenableBuilder(
          valueListenable: monthsBox.listenable(),
          builder: (context, Box<MonthRecord> box, _) {
            if (currentMonth == null) {
              _loadCurrentMonth(); // Add this line
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: currentMonth!.days.length,
              itemBuilder: (context, index) {
                return DayCard(
                  dayRecord: currentMonth!.days[index],
                  index: index,
                  isExpanded: expandedStates[index],
                  onExpandToggle: (index) {
                    setState(() {
                      expandedStates[index] = !expandedStates[index];
                    });
                  },
                  onDelete: (index) {
                    setState(() {
                      currentMonth!.totalSpent -=
                          currentMonth!.days[index].totalSpent;
                      currentMonth!.days.removeAt(index);
                      expandedStates.removeAt(index);
                      monthsBox.put(currentMonth!.key, currentMonth!);
                    });
                  },
                  onAddExpense: (index) async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => AddExpenseDialog(
                        index: index,
                      ),
                    );
                    if (result != null) {
                      _addExpenseToDay(index, result);
                    }
                  },
                  onDayUpdated: () {
                    setState(() {
                      _loadCurrentMonth();
                    });
                  },
                );
              },
            );
          },
        ),
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
}

class DayCard extends StatefulWidget {
  final DayRecord dayRecord;
  final int index;
  final bool isExpanded;
  final Function(int) onExpandToggle;
  final Function(int) onDelete;
  final Function(int) onAddExpense;
  final VoidCallback onDayUpdated;

  const DayCard({
    Key? key,
    required this.dayRecord,
    required this.index,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onDelete,
    required this.onAddExpense,
    required this.onDayUpdated,
  }) : super(key: key);

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Slidable(
        key: ValueKey(widget.index),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDayPage(index: widget.index),
                  ),
                );

                if (result != null && result['refresh'] == true) {
                  setState(() {
                    widget
                        .onDayUpdated(); // Refresh entire state including app bar
                  });
                }
              },
              icon: Icons.edit,
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) async {
                await widget.onDelete(widget.index);
                setState(() {
                  widget
                      .onDayUpdated(); // Refresh entire state including app bar
                });
              },
              icon: Icons.delete,
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => widget.onExpandToggle(widget.index),
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
                    'Day ${widget.index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total spent: Rs. ${widget.dayRecord.totalSpent.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formatDate(widget.dayRecord.date),
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (widget.isExpanded) ...[
                    Divider(),
                    Text(
                      'Detailed Expenses:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...widget.dayRecord.expenses
                        .map((expense) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        expense.name,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        formatTime(expense.time),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                      Text(
                                        'Rs. ${expense.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700]),
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
                            ))
                        .toList(),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => widget.onAddExpense(widget.index),
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
      ),
    );
  }
}
