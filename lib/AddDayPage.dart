import 'package:flutter/material.dart';
import 'utilities/data.dart';

class AddDayPage extends StatefulWidget {
  const AddDayPage({super.key});

  @override
  _AddDayPageState createState() => _AddDayPageState();
}

class _AddDayPageState extends State<AddDayPage> {
  final List<places> expenses = [];
  final TextEditingController amountController = TextEditingController();
  final TextEditingController customPlaceController = TextEditingController();
  final TextEditingController itemscontroller = TextEditingController();

  String? selectedPlace;

  @override
  void dispose() {
    amountController.dispose();
    customPlaceController.dispose();
    itemscontroller.dispose();
    super.dispose();
  }

  void addExpense() {
    final place =
        selectedPlace == 'Other' ? customPlaceController.text : selectedPlace;
    final amountText = amountController.text;

    if (place != null && place.isNotEmpty && amountText.isNotEmpty) {
      final amount = double.tryParse(amountText);
      if (amount != null) {
        setState(() {
          expenses.add(
              places(name: place, spent: amount, item: itemscontroller.text));
        });
        amountController.clear();
        customPlaceController.clear();
        itemscontroller.clear();
        selectedPlace = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Day'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Expenses for the New Day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPlace,
              decoration: AppStyles.getInputDecoration(context,
                  labelText: 'Select Place',
                  hintText: 'Choose Point of Expenditure'),
              items: [
                ...options.map((place) {
                  return DropdownMenuItem<String>(
                    value: place,
                    child: Text(place),
                  );
                }),
                DropdownMenuItem<String>(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPlace = value;
                });
              },
            ),
            if (selectedPlace == 'Other') ...[
              SizedBox(height: 16),
              TextField(
                controller: customPlaceController,
                decoration: AppStyles.getInputDecoration(context,
                    labelText: 'Custom Place', hintText: 'Enter Place Name'),
              ),
            ],
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: AppStyles.getInputDecoration(context,
                  labelText: 'Amount Spent', hintText: 'Enter Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: itemscontroller,
              decoration: AppStyles.getInputDecoration(context,
                  labelText: 'Item', hintText: 'Enter Item Name (Optional)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 6,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
                minimumSize: Size(120, 36),
              ),
              onPressed: addExpense,
              child: Text('Add Expense'),
            ),
            SizedBox(height: 20),
            Text(
              'Expenses for the Day:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return ListTile(
                    title: Text(expense.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount: Rs ${expense.spent.toStringAsFixed(2)}'),
                        if (expense.item != null) ...[
                          Text(
                            expense.item!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        onPressed: () {
          if (expenses.isNotEmpty) {
            // Create a new dayexpense object and pass it back
            final newDay = dayexpense(expenses);
            Navigator.pop(context, newDay); // Pass the new dayexpense back
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
