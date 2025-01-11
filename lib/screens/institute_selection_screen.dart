// institute_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:giki_expense/utilities/data.dart';

class InstituteSelectionScreen extends StatefulWidget {
  @override
  _InstituteSelectionScreenState createState() =>
      _InstituteSelectionScreenState();
}

class _InstituteSelectionScreenState extends State<InstituteSelectionScreen> {
  final PlacesManager _placesManager = PlacesManager();
  List<String> selectedPlaces = [];
  TextEditingController customPlaceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePlacesManager();
  }

  Future<void> _initializePlacesManager() async {
    try {
      await _placesManager.initPlaces();
      setState(() {}); // Refresh UI after initialization
    } catch (e) {
      print('Error initializing PlacesManager: $e');
    }
  }

  Future<void> _handleSaveAndContinue() async {
    try {
      if (selectedPlaces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one place')),
        );
        return;
      }

      await _placesManager.savePlaces(selectedPlaces);
      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving places: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving places. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Institute'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Institute Selection
            Card(
              child: Column(
                children: institutePlaces.keys.map((institute) {
                  return ListTile(
                    title: Text(institute),
                    onTap: () {
                      setState(() {
                        selectedPlaces = List.from(institutePlaces[institute]!);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Text('Selected Places:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
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
            // Add custom place
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customPlaceController,
                    decoration: InputDecoration(
                      labelText: 'Add Custom Place',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (customPlaceController.text.isNotEmpty) {
                      setState(() {
                        selectedPlaces.add(customPlaceController.text);
                        customPlaceController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _handleSaveAndContinue,
                child: Text(
                  'Save and Continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
