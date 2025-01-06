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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _monthNameController,
              decoration: InputDecoration(
                labelText: 'Month Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText: 'Intended Budget',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            ElevatedButton(
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
              child: Text('Start Month'),
            ),
          ],
        ),
      ),
    );
  }
}
