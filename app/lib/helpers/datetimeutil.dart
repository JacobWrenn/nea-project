import 'package:flutter/material.dart';

// helps when formatting dates and times to add leading 0
String doubleDigit(int digit) {
  String digitString = digit.toString();
  if (digitString.length == 1) {
    return "0$digitString";
  }
  return digitString;
}

String formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return "${doubleDigit(date.day)}/${doubleDigit(date.month)}/${date.year}";
}

String formatTime(TimeOfDay time) {
  return "${doubleDigit(time.hour)}:${doubleDigit(time.minute)}";
}

TimeOfDay getTime(String time) {
  final parts = time.split(":");
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

bool withinHour(String time) {
  final parts = time.split(":");
  final today = DateTime.now();
  // subtracts 1 hour from the target time
  final dateTime = DateTime(today.year, today.month, today.day,
          int.parse(parts[0]), int.parse(parts[1]))
      .subtract(Duration(hours: 1));
  // if target time minus 1 hour is smaller than or equal to the current time then this means target time is within an hour of now
  return today.compareTo(dateTime) >= 0;
}

// used for sorting loadings based on their date and time properties
int compare(a, b) {
  final aDate = getDateTime(a);
  final bDate = getDateTime(b);
  return aDate.compareTo(bDate);
}

DateTime getDateTime(point) {
  final parts = point["time"].split(":");
  final date = DateTime.parse(point["date"]);
  return DateTime(date.year, date.month, date.day, int.parse(parts[0]),
      int.parse(parts[1]));
}
