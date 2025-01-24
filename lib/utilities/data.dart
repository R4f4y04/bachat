import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

final Map<String, List<String>> institutePlaces = {
  'GIKI': [
    'Raju',
    'Ayan',
    'Hot N Spicy',
    'Karachi Biryani',
    'Mess',
    'Tahir',
    'General Store',
    'GIKAFE',
    'AsrarBucks',
    'Shakes Stores',
    'Fruit Shop',
    'Barber',
    'Stationery'
  ],
  'NUST': [
    'C3A Cafe',
    'Concordia 1',
    'Concordia 2',
    'Concordia 3/South Edge Cafe',
    'C1 Mart',
    'C2 Mart',
    'Coffee Lounge',
    'Retro Cafe',
    'SEECS Khaapa',
    'NICE Cafe',
    'NSTP/Inno Cafe',
    'Ez Bike',
    'NUST Medical Center',
    'S³H Cafe',
    'SMME Cafe'
  ],

  'LUMS': [
    'Pepsi Dining Center (PDC)',
    'Baradari',
    'Zakir',
    'Subway',
    'Chinese Corner',
    'Juice Shop',
    'Delish',
    'Jam and Java',
    'Baithak',
    'LUMS Mart',
    'Khokha'
  ],
  'BNU': [],
  'Fast': [],
  'COMSATS': [],
  'Bahria': [],

  // Add more institutes as needed
};

// Empty list that will be populated based on user selection
List<String> options = [];

class PlacesManager {
  static const String placesBoxName = 'places_prefs';
  static const String placesKey = 'selected_places';
  late Box placesBox;

  Future<void> initPlaces() async {
    placesBox = await Hive.openBox(placesBoxName);
    List<String>? savedPlaces = placesBox.get(placesKey)?.cast<String>();
    if (savedPlaces != null) {
      options = savedPlaces;
    }
  }

  Future<void> savePlaces(List<String> selectedPlaces) async {
    options = selectedPlaces;
    await placesBox.put(placesKey, selectedPlaces);
  }

  // Helper method to get places for an institute
  List<String> getInstitutePlaces(String institute) {
    return institutePlaces[institute] ?? [];
  }

  // Add a custom place to options
  Future<void> addCustomPlace(String place) async {
    if (!options.contains(place)) {
      options.add(place);
      await savePlaces(options);
    }
  }
}

class dayexpense {
  double total = 0;
  late List<places> hotels;
  late bool expanded;
  late String date;

  dayexpense(this.hotels) {
    calctotal();

    expanded = false;
    date = DateFormat('d MMMM').format(DateTime.now());
  }

  void recalcTotal() {
    total = 0;
    for (var hotel in hotels) {
      total += hotel.spent;
    }
  }

  void calctotal() {
    double temp = 0;
    for (var i in hotels) {
      temp += i.spent;
    }
    total += temp;
  }

  void addplace(places place) {
    hotels.add(place);
    total = 0;
    calctotal();
  }

  String names() {
    String result = "";
    for (var i in hotels) {
      result += i.name;
      result += " , ";
    }
    return result;
  }
}

class places {
  String name;
  double spent;
  late String time;
  String? item;
  places({required this.name, required this.spent, this.item}) {
    var format = DateFormat('hh:mm a');
    time = format.format(DateTime.now());
  }
}

List<dayexpense> data = [
  dayexpense(
    [places(name: "Raju", spent: 10000)],
  ),
  dayexpense(
    [places(name: "ayaan", spent: 20000)],
  ),
  dayexpense(
    [places(name: "ayan", spent: 800), places(name: "Hot n Spicy", spent: 900)],
  )
];

class MonthData {
  late String monthName;
  late List<dayexpense> monthlyData;
}

List<MonthData> monthsData = [];

class ThemeManager with ChangeNotifier {
  static const String themeBoxName = 'theme_prefs';
  static const String themeKey = 'is_dark';
  late Box themeBox;
  bool _isDarkTheme = true;

  ThemeManager() {
    initTheme();
  }

  bool get isDarkTheme => _isDarkTheme;
  ThemeData get currentTheme => _isDarkTheme ? darkTheme : lightTheme;

  Future<void> initTheme() async {
    themeBox = await Hive.openBox(themeBoxName);
    _isDarkTheme = themeBox.get(themeKey, defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await themeBox.put(themeKey, _isDarkTheme);
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.grey[100],
  iconTheme: IconThemeData(color: Colors.grey[800]),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.grey[900],
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.grey[900],
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.grey[900]),
    bodyMedium: TextStyle(color: Colors.grey[800]),
    titleLarge: TextStyle(
      color: Colors.grey[900],
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue),
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.grey[100],
    labelStyle: TextStyle(color: Colors.grey[700]),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  dividerColor: Colors.grey[300],
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Color(0xFF121212),
  cardColor: Color(0xFF1E1E1E),
  iconTheme: IconThemeData(color: Colors.grey[400]),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF121212),
    foregroundColor: Colors.grey[200],
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.grey[200],
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.grey[300]),
    bodyMedium: TextStyle(color: Colors.grey[400]),
    titleLarge: TextStyle(
      color: Colors.grey[200],
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[700]!),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Color(0xFF1E1E1E),
    labelStyle: TextStyle(color: Colors.grey[500]),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  dividerColor: Colors.grey[800],
);

class AppStyles {
  static InputDecoration getInputDecoration(BuildContext context,
      {String? labelText, String? hintText}) {
    final theme = Theme.of(context);
    return InputDecoration(
      filled: true,
      fillColor: theme.cardColor,
      labelText: labelText,
      hintText: hintText,
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
  }
}
