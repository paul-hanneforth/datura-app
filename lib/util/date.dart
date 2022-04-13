import 'package:flutter/material.dart';

class BetterDateTime extends DateTime {

  BetterDateTime() : super.now();

  BetterDateTime.fromDateTime(DateTime dateTime) : super.fromMicrosecondsSinceEpoch(dateTime.microsecondsSinceEpoch);
  BetterDateTime.at({
    int year = 0,
    int month = 0,
    int day = 0,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
  }) : super(year, month, day, hour, minute, second, millisecond);

  String format({ bool padZeros = false }) {
    return day.toString().padLeft(padZeros ? 2 : 1, "0") + "." + month.toString().padLeft(padZeros ? 2 : 1, "0") + "." + year.toString().padLeft(padZeros ? 4 : 1, "0");
  }
  String timeOfDay({ bool padZeros = false }) {
    return hour.toString().padLeft(padZeros ? 2 : 1, "0") + ":" + minute.toString().padLeft(padZeros ? 2 : 1, "0");
  }

  String detailedFormat() {
    return "$hour : $minute : $second @ $day.$month.$year";
    // return hour.toString() + ":" + minute.toString() + ":" + millisecond.toString() + "@" + day.toString() + "." + month.toString() + "." + year.toString();
  }
  String get monthName {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months.elementAt(month - 1);
  }

  @override
  String toString() {
    return detailedFormat();
  }

  BetterDateTime toDayStart() {
    final BetterDateTime dayStart = subtract(Duration(microseconds: microsecond))
      .subtract(Duration(milliseconds: millisecond))
      .subtract(Duration(seconds: second))
      .subtract(Duration(minutes: minute))
      .subtract(Duration(hours: hour));

    return dayStart;
  }
  BetterDateTime toDayEnd() {
    final BetterDateTime dayEnd = toDayStart().add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
    return dayEnd;
  }
  BetterDateTime toMonthStart() {
    final BetterDateTime monthStart = subtract(Duration(microseconds: microsecond))
      .subtract(Duration(milliseconds: millisecond))
      .subtract(Duration(seconds: second))
      .subtract(Duration(minutes: minute))
      .subtract(Duration(hours: hour))
      .subtract(Duration(days: day))
      .add(const Duration(days: 1));
    
    return monthStart;
  }
  BetterDateTime toMonthEnd() {
    final BetterDateTime monthEnd = BetterDateTime.fromDateTime(month == 12 ? DateTime(year + 1, 1, 0) : DateTime(year, month + 1, 0));
    return monthEnd;
  }
  BetterDateTime toYearStart() {
    return BetterDateTime.fromDateTime(DateTime(year, 0, 0, 0, 0, 0, 0));
  }
  BetterDateTime toYearEnd() {
    return BetterDateTime.fromDateTime(DateTime(year, 12, 31, 23, 59, 59, 999));
  }

  /// Returns a new date with one month added to it.
  /// e.g. 20.04.2022 turns to 20.05.2022
  /// be aware: 31.01.2022 would turn to 28.02.2022
  BetterDateTime nextMonth() {
    int daysInNextMonth = month == 12 ? DateTime(year + 1, 2, 0).day : DateTime(year, month + 2, 0).day;
    final int newDay = day > daysInNextMonth ? daysInNextMonth : day;
    final int newMonth = month == 12 ? 1 : month + 1;
    final int newYear = month == 12 ? year + 1 : year;
    return BetterDateTime.fromDateTime(DateTime(newYear, newMonth, newDay, hour, minute, second, millisecond));
  }

  /// Returns a new date with one month subtracted from it.
  BetterDateTime previousMonth() {
    int daysInPreviousMonth = month == 1 ? DateTime(year - 1, 12, 0).day : DateTime(year, month - 1, 0).day;
    final int newDay = day > daysInPreviousMonth ? daysInPreviousMonth : day;
    final int newMonth = month == 1 ? 12 : month - 1;
    final int newYear = month == 1 ? year - 1 : year;
    return BetterDateTime.fromDateTime(DateTime(newYear, newMonth, newDay, hour, minute, second, millisecond));
  }

  @override
  BetterDateTime add(Duration duration) {
    final DateTime newDateTime = super.add(duration);
    return BetterDateTime.fromDateTime(newDateTime);
  }

  @override
  BetterDateTime subtract(Duration duration) {
    final DateTime newDateTime = super.subtract(duration);
    return BetterDateTime.fromDateTime(newDateTime);
  }

  int serialize() {
    return microsecondsSinceEpoch;
  }
  BetterDateTime.deserialize(int serializedNewDate) : super.fromMicrosecondsSinceEpoch(serializedNewDate);

}
class BetterDateTimeRange extends DateTimeRange {
  
  @override
  // ignore: overridden_fields
  final BetterDateTime start;
  @override
  // ignore: overridden_fields
  final BetterDateTime end;

  BetterDateTimeRange({ 
    required this.start, 
    required this.end 
  }) : super(start: start, end: end);

  // BetterDateTimeRange.today() : start = NewDate().toDayStart(), end = NewDate().toDayEnd(), super(start: NewDate().toDayStart(), end: NewDate().toDayEnd());

  static BetterDateTimeRange today() => BetterDateTimeRange(start: BetterDateTime().toDayStart(), end: BetterDateTime().toDayEnd());
  static BetterDateTimeRange thisMonth() => BetterDateTimeRange(start: BetterDateTime().toMonthStart(), end: BetterDateTime().toMonthEnd());
  static BetterDateTimeRange thisYear() => BetterDateTimeRange(start: BetterDateTime().toYearStart(), end: BetterDateTime().toYearEnd());
  static BetterDateTimeRange fromDateTimeRange(DateTimeRange timeRange) => BetterDateTimeRange(start: BetterDateTime.fromDateTime(timeRange.start), end: BetterDateTime.fromDateTime(timeRange.end));

  BetterDateTimeRange shift(Duration duration) => BetterDateTimeRange(start: start.add(duration), end: end.add(duration));

}

