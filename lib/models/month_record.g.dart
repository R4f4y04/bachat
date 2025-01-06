// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthRecordAdapter extends TypeAdapter<MonthRecord> {
  @override
  final int typeId = 0;

  @override
  MonthRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthRecord(
      monthName: fields[0] as String,
      startDate: fields[1] as DateTime,
      intendedBudget: fields[3] as double,
      endDate: fields[2] as DateTime?,
      totalSpent: fields[4] as double,
      days: (fields[5] as List?)?.cast<DayRecord>(),
    );
  }

  @override
  void write(BinaryWriter writer, MonthRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.monthName)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.intendedBudget)
      ..writeByte(4)
      ..write(obj.totalSpent)
      ..writeByte(5)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayRecordAdapter extends TypeAdapter<DayRecord> {
  @override
  final int typeId = 1;

  @override
  DayRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayRecord(
      date: fields[0] as String,
      expenses: (fields[1] as List).cast<ExpenseRecord>(),
      totalSpent: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DayRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.expenses)
      ..writeByte(2)
      ..write(obj.totalSpent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseRecordAdapter extends TypeAdapter<ExpenseRecord> {
  @override
  final int typeId = 2;

  @override
  ExpenseRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseRecord(
      name: fields[0] as String,
      amount: fields[1] as double,
      time: fields[2] as String,
      items: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
