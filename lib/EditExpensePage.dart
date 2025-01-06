import 'package:flutter/material.dart';
import 'package:giki_expense/models/month_record.dart';
import 'package:hive/hive.dart';
import 'data.dart';

class EditDayPage extends StatefulWidget {
  final int index; // The index of the selected day in the data list

  const EditDayPage({super.key, required this.index});

  @override
  _EditDayPageState createState() => _EditDayPageState();
}

class _EditDayPageState extends State<EditDayPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController customPlaceController = TextEditingController();
  final TextEditingController itemscontroller = TextEditingController();
  String? selectedPlace;

  late List<ExpenseRecord> expenses;
  late final MonthRecord currentMonth;

  @override
  void initState() {
    super.initState();
    final monthsBox = Hive.box<MonthRecord>('months');
    currentMonth = monthsBox.values.last;
    expenses = List.from(currentMonth.days[widget.index].expenses);
  }

  @override
  void dispose() {
    amountController.dispose();
    customPlaceController.dispose();
    itemscontroller.dispose();
    super.dispose();
  }

  void _saveChanges(
      int expenseIndex, String newPlace, double newAmount, String? newItems) {
    setState(() {
      final updatedExpense = ExpenseRecord(
        name: newPlace,
        amount: newAmount,
        time: DateTime.now().toString(),
        items: newItems,
      );

      // Update the expense
      double oldAmount = expenses[expenseIndex].amount;
      expenses[expenseIndex] = updatedExpense;

      // Update totals
      currentMonth.days[widget.index].totalSpent += (newAmount - oldAmount);
      currentMonth.totalSpent += (newAmount - oldAmount);

      // Save to Hive
      final monthsBox = Hive.box<MonthRecord>('months');
      monthsBox.put(currentMonth.key, currentMonth);
    });
  }

  void _deleteExpense(int expenseIndex) {
    setState(() {
      // Subtract amount from totals
      final deletedAmount = expenses[expenseIndex].amount;
      currentMonth.days[widget.index].totalSpent -= deletedAmount;
      currentMonth.totalSpent -= deletedAmount;

      // Remove expense
      expenses.removeAt(expenseIndex);

      // Save to Hive
      final monthsBox = Hive.box<MonthRecord>('months');
      monthsBox.put(currentMonth.key, currentMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expenses for Day ${widget.index + 1}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, expenseIndex) {
            final expense = expenses[expenseIndex];
            final TextEditingController customPlaceController =
                TextEditingController(text: expense.name);
            final TextEditingController amountController =
                TextEditingController(text: expense.amount.toString());
            final TextEditingController itemsController =
                TextEditingController(text: expense.items ?? '');

            // Rest of your existing UI code...
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: customPlaceController,
                      decoration: InputDecoration(
                          fillColor:
                              Theme.of(context).appBarTheme.backgroundColor,
                          border: OutlineInputBorder(),
                          labelText: 'Place',
                          labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor)),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                          fillColor:
                              Theme.of(context).appBarTheme.backgroundColor,
                          border: OutlineInputBorder(),
                          labelText: 'Amount Spent',
                          labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor)),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: itemsController,
                      decoration: InputDecoration(
                          fillColor:
                              Theme.of(context).appBarTheme.backgroundColor,
                          border: OutlineInputBorder(),
                          labelText: 'Items',
                          hintText: "Optional",
                          labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor)),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).appBarTheme.foregroundColor,
                            foregroundColor:
                                Theme.of(context).appBarTheme.backgroundColor,
                          ),
                          onPressed: () {
                            final newPlace = customPlaceController.text;
                            final newAmountText = amountController.text;
                            final newAmount = double.tryParse(newAmountText);

                            if (newPlace.isNotEmpty && newAmount != null) {
                              _saveChanges(expenseIndex, newPlace, newAmount,
                                  itemsController.text);
                            }
                          },
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).appBarTheme.backgroundColor,
                            foregroundColor:
                                Theme.of(context).appBarTheme.foregroundColor,
                          ),
                          onPressed: () {
                            _deleteExpense(expenseIndex);
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        onPressed: () {
          if (expenses.isNotEmpty) {
            // Save and go back with updated data
            currentMonth.days[widget.index].expenses.clear();
            currentMonth.days[widget.index].expenses.addAll(expenses);
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please add at least one expense.')),
            );
          }
        },
        label: Text('Save Day'),
        icon: Icon(Icons.save),
      ),
    );
  }
}
