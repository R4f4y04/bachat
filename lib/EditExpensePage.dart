import 'package:flutter/material.dart';
import 'package:giki_expense/models/month_record.dart';
import 'package:hive/hive.dart';
import 'package:giki_expense/utilities/data.dart';

class EditDayPage extends StatefulWidget {
  final int index; // The index of the selected day in the data list

  const EditDayPage({super.key, required this.index});

  @override
  _EditDayPageState createState() => _EditDayPageState();
}

class _EditDayPageState extends State<EditDayPage> {
  late Box<MonthRecord> monthsBox;
  late MonthRecord currentMonth;
  late List<ExpenseRecord> expenses;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController customPlaceController = TextEditingController();
  final TextEditingController itemscontroller = TextEditingController();
  String? selectedPlace;

  @override
  void initState() {
    super.initState();
    monthsBox = Hive.box<MonthRecord>('months');
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

      // Only update the local expenses array
      expenses[expenseIndex] = updatedExpense;

      // Hide keyboard
      FocusScope.of(context).unfocus();
    });
  }

  void _deleteExpense(int expenseIndex) {
    setState(() {
      expenses.removeAt(expenseIndex);

      // Only remove from local state
      // Updates to Hive will happen when Save Day is pressed
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
                        decoration: AppStyles.getInputDecoration(context,
                            labelText: 'Place', hintText: 'Enter a place'),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        decoration: AppStyles.getInputDecoration(context,
                            labelText: 'Amount', hintText: 'Enter amount'),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: itemsController,
                        decoration: AppStyles.getInputDecoration(context,
                            labelText: 'Items', hintText: 'Enter items'),
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
          onPressed: () async {
            if (expenses.isNotEmpty) {
              try {
                final latestMonth = monthsBox.values.last;

                // Calculate new day total
                double newDayTotal =
                    expenses.fold(0.0, (sum, exp) => sum + exp.amount);

                // Update day expenses first
                latestMonth.days[widget.index].expenses.clear();
                latestMonth.days[widget.index].expenses.addAll(expenses);
                latestMonth.days[widget.index].totalSpent = newDayTotal;

                // Recalculate month total from all days
                latestMonth.totalSpent = latestMonth.days
                    .fold(0.0, (sum, day) => sum + day.totalSpent);

                print('Recalculated month total: ${latestMonth.totalSpent}');

                // Save to Hive
                await monthsBox.put(latestMonth.key, latestMonth);
                await monthsBox.flush();

                // Verify save
                final savedMonth = monthsBox.get(latestMonth.key);
                print('Verified month total: ${savedMonth?.totalSpent}');

                Navigator.pop(context, {'refresh': true});
              } catch (e) {
                print('Error saving data: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving changes: $e')),
                );
              }
            }
          },
          label: Text('Save Day'),
          icon: Icon(Icons.save),
        ));
  }
}
