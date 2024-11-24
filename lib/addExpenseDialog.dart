import 'package:flutter/material.dart';
import 'data.dart';

class AddExpenseDialog extends StatefulWidget {
  final int index;

  const AddExpenseDialog({super.key, required this.index});

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  String? selectedPlace;

  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Expense',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPlace,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Place',
              ),
              items: options.map((place) {
                return DropdownMenuItem<String>(
                  value: place,
                  child: Text(place),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPlace = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount Spent',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final place = selectedPlace;
                final amount = amountController.text;

                if (place != null && amount.isNotEmpty) {
                  // Save the expense and close the dialog
                  //Navigator.of(context).pop({'place': place, 'amount': amount});
                  places temp =
                      places(name: place, spent: double.parse(amount));
                  data[widget.index].addplace(temp);

                  Navigator.pop(context);
                } else {
                  // Show an error if inputs are invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please select a place and enter an amount.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
