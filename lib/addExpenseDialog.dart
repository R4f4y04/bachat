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
  final TextEditingController customPlaceController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    customPlaceController.dispose();
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
                final place = selectedPlace == 'Other'
                    ? customPlaceController.text
                    : selectedPlace;
                final amountText = amountController.text;

                if (place != null &&
                    place.isNotEmpty &&
                    amountText.isNotEmpty) {
                  final amount = double.tryParse(amountText);
                  if (amount != null) {
                    // Save the expense and close the dialog
                    final temp = places(name: place, spent: amount);
                    data[widget.index].addplace(temp);

                    Navigator.pop(context);
                  } else {
                    // Show an error if the amount is invalid
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid amount.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  // Show an error if inputs are incomplete
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please select a place (or enter a custom one) and provide an amount.'),
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
