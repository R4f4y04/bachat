import 'package:flutter/material.dart';
import 'data.dart';

class AddDayPage extends StatefulWidget {
  @override
  _AddDayPageState createState() => _AddDayPageState();
}

class _AddDayPageState extends State<AddDayPage> {
  final List<places> expenses = [];
  final TextEditingController amountController = TextEditingController();
  final TextEditingController customPlaceController = TextEditingController();
  String? selectedPlace;

  @override
  void dispose() {
    amountController.dispose();
    customPlaceController.dispose();
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
          expenses.add(places(name: place, spent: amount));
        });
        amountController.clear();
        customPlaceController.clear();
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Place',
              ),
              items: [
                ...options.map((place) {
                  return DropdownMenuItem<String>(
                    value: place,
                    child: Text(place),
                  );
                }).toList(),
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Custom Place',
                ),
              ),
            ],
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount Spent',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
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
                    subtitle:
                        Text('Amount: Rs ${expense.spent.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
