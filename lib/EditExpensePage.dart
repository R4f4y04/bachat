import 'package:flutter/material.dart';
import 'data.dart';

class EditDayPage extends StatefulWidget {
  final int index; // The index of the selected day in the data list

  const EditDayPage({super.key, required this.index});

  @override
  _EditDayPageState createState() => _EditDayPageState();
}

class _EditDayPageState extends State<EditDayPage> {
  late List<places> placesList;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController customPlaceController = TextEditingController();
  final TextEditingController itemscontroller = TextEditingController();
  String? selectedPlace;

  @override
  void initState() {
    super.initState();
    placesList = data[widget.index].hotels; // Get places for the selected day
  }

  @override
  void dispose() {
    amountController.dispose();
    customPlaceController.dispose();
    itemscontroller.dispose();
    super.dispose();
  }

  void _saveChanges(
      int placeIndex, String newPlace, double newSpent, String? newItem) {
    setState(() {
      placesList[placeIndex].name = newPlace;
      placesList[placeIndex].spent = newSpent;
      placesList[placeIndex].item = newItem;
      data[widget.index].recalcTotal(); // Recalculate total
    });
  }

  void _deletePlace(int placeIndex) {
    setState(() {
      placesList.removeAt(placeIndex); // Remove place
      data[widget.index].calctotal(); // Recalculate total
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expenses for ${data[widget.index].date}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: placesList.length,
          itemBuilder: (context, placeIndex) {
            final place = placesList[placeIndex];
            final TextEditingController customPlaceController =
                TextEditingController(text: place.name);
            final TextEditingController amountController =
                TextEditingController(text: place.spent.toString());
            final TextEditingController itemsController =
                TextEditingController(text: place.item ?? '');

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: customPlaceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Place',
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Amount Spent',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: itemsController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Items',
                        hintText: "Optional",
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).appBarTheme.backgroundColor,
                            foregroundColor:
                                Theme.of(context).appBarTheme.foregroundColor,
                          ),
                          onPressed: () {
                            final newPlace = customPlaceController.text;
                            final newAmountText = amountController.text;
                            final newAmount = double.tryParse(newAmountText);

                            if (newPlace.isNotEmpty && newAmount != null) {
                              _saveChanges(placeIndex, newPlace, newAmount,
                                  itemsController.text);
                            }
                          },
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _deletePlace(placeIndex);
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
        onPressed: () {
          if (placesList.isNotEmpty) {
            // Save and go back with updated data
            final updatedDay = dayexpense(placesList);
            Navigator.pop(context, updatedDay);
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
