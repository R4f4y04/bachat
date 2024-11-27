import 'package:flutter/material.dart';
import 'package:giki_expense/AddDayPage.dart';
import 'package:giki_expense/EditExpensePage.dart';
import 'package:giki_expense/addExpenseDialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'data.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double MonthlySpent = 0;

  void deleteDay(index) {
    data[index].total = 0;
    data[index].hotels.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Day ${index + 1} Deleted.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void calculateMonthly() {
    MonthlySpent = 0;
    for (var day in data) {
      MonthlySpent += day.total;
    }
  }

  @override
  void initState() {
    super.initState();
    for (var day in data) {
      day.expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    calculateMonthly();
    final themeManager = Provider.of<ThemeManager>(context);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          // Toggle Theme IconButton
          IconButton(
            icon: Icon(
                themeManager.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeManager.toggleTheme();
            },
          ),
        ],
        leading: PopupMenuButton(
          color: Theme.of(context).appBarTheme.backgroundColor,
          itemBuilder: (context) {
            return [
              PopupMenuItem(child: Text("Save Month")),
              PopupMenuItem(child: Text("Expenditure History")),
            ];
          },
          onSelected: (value) {},
        ),
        title: Text("Month's Spent Rs ${MonthlySpent}"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final day = index + 1;
          final dayData = data[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Slidable(
              key: ValueKey(day), // Unique key for the Slidable
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EditDayPage(index: index);
                      })).then((value) {
                        setState(() {});
                      });
                    },
                    icon: Icons.edit,
                    backgroundColor: Colors.transparent,
                    foregroundColor:
                        Theme.of(context).appBarTheme.foregroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SlidableAction(
                    onPressed: (_) {
                      setState(() {
                        deleteDay(index);
                      });
                    },
                    icon: Icons.delete,
                    backgroundColor: Colors.transparent,
                    foregroundColor:
                        Theme.of(context).appBarTheme.foregroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  // Toggle the expanded state of the tile
                  setState(() {
                    data[index].expanded = !data[index].expanded;
                  });
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                          dayData.date,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        if (data[index].expanded) ...[
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          place.name,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          place.time,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
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
                                    if (place.item != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          place.item!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            fontStyle: FontStyle.italic,
                                          ),
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
                                setState(
                                    () {}); // Refresh UI after dialog closes
                              });
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add Expense'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).appBarTheme.backgroundColor,
                              foregroundColor:
                                  Theme.of(context).appBarTheme.foregroundColor,
                              minimumSize: Size(120, 36),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
