import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'home.dart';

void main() {
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
      home: Home(),
    );
  }
}
