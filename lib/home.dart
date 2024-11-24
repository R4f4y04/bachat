import 'package:flutter/material.dart';
import 'package:giki_expense/AddDayPage.dart';
import 'package:giki_expense/addExpenseDialog.dart';
import 'data.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // To track which tiles are expanded
  List<bool> expandedTiles = [];

  @override
  void initState() {
    super.initState();
    expandedTiles = List<bool>.filled(data.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Calculator'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final day = index + 1;
          final dayData = data[index];

          return GestureDetector(
            onTap: () {
              // Toggle the expanded state of the tile
              setState(() {
                expandedTiles[index] = !expandedTiles[index];
              });
            },
            child: Card(
              margin: EdgeInsets.only(bottom: 10),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day $day',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total spent: Rs ${dayData.total.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Places: ${dayData.names()}',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (expandedTiles[index]) ...[
                      Divider(),
                      Text(
                        'Detailed Expenses:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: dayData.hotels.map((place) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  place.name,
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Rs ${place.spent.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AddExpenseDialog(
                                index: index,
                              );
                            },
                          ).then((_) {
                            setState(() {}); // Refresh UI after dialog closes
                          });
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add Expense'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(120, 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddDayPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDayPage(),
            ),
          ).then((result) {
            if (result != null && result is dayexpense) {
              setState(() {
                data.add(result);
                expandedTiles.add(false); // Keep expandedTiles in sync
              });
            }
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Day',
      ),
    );
  }
}
