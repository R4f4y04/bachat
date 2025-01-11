import 'package:flutter/material.dart';
import 'package:giki_expense/home.dart';
import 'package:hive/hive.dart';
import '../models/month_record.dart';
import '../utilities/data.dart';

class NewMonthScreen extends StatefulWidget {
  const NewMonthScreen({super.key});

  @override
  _NewMonthScreenState createState() => _NewMonthScreenState();
}

class _NewMonthScreenState extends State<NewMonthScreen> {
  final _monthNameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _customPlaceController = TextEditingController();
  final _placesManager = PlacesManager();
  String? selectedInstitute;
  List<String> selectedPlaces = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlacesManager();
  }

  Future<void> _initializePlacesManager() async {
    try {
      await _placesManager.initPlaces();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing PlacesManager: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing places. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _monthNameController.dispose();
    _budgetController.dispose();
    _customPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: theme.cardColor,
      labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Start New Month'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _monthNameController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Month Name',
                  hintText: 'Enter month name',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _budgetController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Intended Budget',
                  hintText: 'Enter budget amount',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedInstitute,
                decoration: inputDecoration.copyWith(
                  labelText: 'Select Institute',
                ),
                dropdownColor: theme.cardColor,
                items: [
                  ...institutePlaces.keys.map((institute) => DropdownMenuItem(
                        value: institute,
                        child: Text(institute),
                      )),
                  DropdownMenuItem(
                    value: 'custom',
                    child: Text('Custom Places'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedInstitute = value;
                    if (value != 'custom') {
                      selectedPlaces = List.from(institutePlaces[value] ?? []);
                    } else {
                      selectedPlaces = [];
                    }
                  });
                },
              ),
              if (selectedInstitute != null) ...[
                SizedBox(height: 20),
                Text(
                  'Selected Places:',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedPlaces.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(selectedPlaces[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              selectedPlaces.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customPlaceController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Add Custom Place',
                          hintText: 'Enter place name',
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        if (_customPlaceController.text.isNotEmpty) {
                          setState(() {
                            selectedPlaces.add(_customPlaceController.text);
                            _customPlaceController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
              SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (_monthNameController.text.isNotEmpty &&
                      _budgetController.text.isNotEmpty &&
                      selectedPlaces.isNotEmpty) {
                    try {
                      await _placesManager.savePlaces(selectedPlaces);
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
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating new month: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please fill all fields and select at least one place',
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Start Month',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
