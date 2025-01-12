import 'package:flutter/material.dart';
import 'package:giki_expense/models/month_record.dart';
import 'utilities/data.dart';

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
  final TextEditingController itemscontroller = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    customPlaceController.dispose();
    itemscontroller.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final place =
        selectedPlace == 'Other' ? customPlaceController.text : selectedPlace;
    final amountText = amountController.text;

    if (place != null && place.isNotEmpty && amountText.isNotEmpty) {
      final amount = double.tryParse(amountText);
      if (amount != null) {
        // Create new ExpenseRecord and return it
        final newExpense = ExpenseRecord(
          name: place,
          amount: amount,
          time: DateTime.now().toString(),
          items: itemscontroller.text.isEmpty ? null : itemscontroller.text,
        );
        Navigator.pop(context, newExpense);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid amount.')),
        );
      }
    }
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
              decoration: AppStyles.getInputDecoration(context,
                  labelText: 'Select Place'),
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
                    labelText: 'Custom Place'),
              ),
            ],
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              decoration: AppStyles.getInputDecoration(context,
                  labelText: 'Amount Spent'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: itemscontroller,
              decoration: AppStyles.getInputDecoration(context,
                  labelText: 'Items', hintText: 'Optional'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 6,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
                minimumSize: Size(120, 36),
              ),
              onPressed: _saveExpense,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
