import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'utilities/data.dart';
import 'home.dart';
import 'models/month_record.dart';
import 'screens/new_month_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giki_expense/screens/onboarding_screen.dart';

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

  // Check if it's first launch
  final prefs = await SharedPreferences.getInstance();
  final showHome = false; //prefs.getBool('showHome') ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeManager,
      child: ExpenseApp(showHome: showHome),
    ),
  );
}

class ExpenseApp extends StatelessWidget {
  final bool showHome;

  const ExpenseApp({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeManager.currentTheme,
      home: showHome
          ? (Hive.box<MonthRecord>('months').isEmpty
              ? NewMonthScreen()
              : Home())
          : const OnboardingScreen(),
    );
  }
}
