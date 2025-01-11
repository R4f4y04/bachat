import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'utilities/data.dart';
import 'home.dart';
import 'models/month_record.dart';
import 'screens/new_month_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MonthRecordAdapter());
  Hive.registerAdapter(DayRecordAdapter());
  Hive.registerAdapter(ExpenseRecordAdapter());

  // Open boxes
  await Hive.openBox<MonthRecord>('months');
  await Hive.openBox('places_prefs');

  final themeManager = ThemeManager();
  await themeManager.initTheme();

  final placesManager = PlacesManager();
  await placesManager.initPlaces();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeManager,
      child: ExpenseApp(),
    ),
  );
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      theme: themeManager.currentTheme,
      home: Hive.box<MonthRecord>('months').isEmpty ? NewMonthScreen() : Home(),
    );
  }
}
