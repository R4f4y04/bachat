import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'utilities/data.dart';
import 'home.dart';
import 'models/month_record.dart';
import 'screens/new_month_screen.dart';

void main() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MonthRecordAdapter());
  Hive.registerAdapter(DayRecordAdapter());
  Hive.registerAdapter(ExpenseRecordAdapter());

  // Open boxes
  await Hive.openBox<MonthRecord>('months');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: ExpenseApp(),
    ),
  );
}

class ExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      theme: themeManager.currentTheme,
      home: Hive.box<MonthRecord>('months').isEmpty ? NewMonthScreen() : Home(),
    );
  }
}
