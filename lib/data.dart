final List<String> options = [
  'Raju',
  'Ayan',
  'Hot N Spicy',
  'Karachi Biryani',
  'Mess',
  'Tahir'
];

class dayexpense {
  int dayno;
  double total = 0;
  late List<places> hotels;
  late bool expanded;

  dayexpense(this.hotels, this.dayno) {
    calctotal();
    dayno++;
    expanded = false;
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
  places({required this.name, required this.spent});
}

List<dayexpense> data = [
  dayexpense([places(name: "Raju", spent: 10000)], 1),
  dayexpense([places(name: "ayaan", spent: 20000)], 2),
  dayexpense([
    places(name: "ayan", spent: 800),
    places(name: "Hot n Spicy", spent: 900)
  ], 3)
];
