import 'package:intl/intl.dart';

final List<String> options = [
  'Raju',
  'Ayan',
  'Hot N Spicy',
  'Karachi Biryani',
  'Mess',
  'Tahir'
];

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
  places({required this.name, required this.spent}) {
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
