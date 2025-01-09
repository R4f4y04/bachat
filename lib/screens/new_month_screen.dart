import 'package:flutter/material.dart';
import 'package:giki_expense/home.dart';
import 'package:hive/hive.dart';
import '../models/month_record.dart';

class NewMonthScreen extends StatefulWidget {
  @override
  _NewMonthScreenState createState() => _NewMonthScreenState();
}

class _NewMonthScreenState extends State<NewMonthScreen> {
  final _monthNameController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start New Month'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _monthNameController,
              decoration: InputDecoration(
                fillColor: Theme.of(context).appBarTheme.backgroundColor,
                labelStyle: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: 'Month Name',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                fillColor: Theme.of(context).appBarTheme.backgroundColor,
                labelStyle: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: 'Intended Budget',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () async {
                if (_monthNameController.text.isNotEmpty &&
                    _budgetController.text.isNotEmpty) {
                  final monthsBox = Hive.box<MonthRecord>('months');
                  final newMonth = MonthRecord(
                    monthName: _monthNameController.text,
                    startDate: DateTime.now(),
                    intendedBudget: double.parse(_budgetController.text),
                  );
                  await monthsBox.add(newMonth);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                }
              },
              child: Text(
                'Start Month',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
