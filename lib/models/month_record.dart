import 'package:hive/hive.dart';
part 'month_record.g.dart';

@HiveType(typeId: 0)
class MonthRecord extends HiveObject {
  @HiveField(0)
  final String monthName;

  @HiveField(1)
  final DateTime startDate;

  @HiveField(2)
  DateTime? endDate;

  @HiveField(3)
  final double intendedBudget;

  @HiveField(4)
  double totalSpent;

  @HiveField(5)
  List<DayRecord> days;

  MonthRecord({
    required this.monthName,
    required this.startDate,
    required this.intendedBudget,
    this.endDate,
    this.totalSpent = 0,
    List<DayRecord>? days,
  }) : days = days ?? [];
}

@HiveType(typeId: 1)
class DayRecord {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final List<ExpenseRecord> expenses;

  @HiveField(2)
  final double totalSpent;

  DayRecord({
    required this.date,
    required this.expenses,
    required this.totalSpent,
  });
}

@HiveType(typeId: 2)
class ExpenseRecord {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String time;

  @HiveField(3)
  final String? items;

  ExpenseRecord({
    required this.name,
    required this.amount,
    required this.time,
    this.items,
  });
}
