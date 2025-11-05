import 'recurrence.dart';

Duration timeToEvent(DateTime eventDate, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  return eventDate.difference(reference);
}

bool isPast(DateTime eventDate, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  return eventDate.isBefore(reference);
}

DateTime nextRecurringDate(DateTime base, Recurrence recurrence, DateTime now) {
  if (recurrence == Recurrence.none) {
    return base;
  }
  if (!base.isBefore(now)) return base;

  switch (recurrence) {
    case Recurrence.weekly:
      final daysDiff = now.difference(base).inDays;
      final weeksToAdd = (daysDiff ~/ 7) + 1;
      return base.add(Duration(days: weeksToAdd * 7));
    case Recurrence.monthly:
      final monthsBetween = _monthsBetween(base, now);
      var candidate = _addMonths(base, monthsBetween);
      if (candidate.isBefore(now)) {
        candidate = _addMonths(base, monthsBetween + 1);
      }
      return candidate;
    case Recurrence.yearly:
      final yearsBetween = now.year - base.year;
      var candidate = _addYearsClamped(base, yearsBetween);
      if (candidate.isBefore(now)) {
        candidate = _addYearsClamped(base, yearsBetween + 1);
      }
      return candidate;
    case Recurrence.none:
      return base;
  }
}

int _monthsBetween(DateTime start, DateTime end) {
  var months = (end.year - start.year) * 12 + (end.month - start.month);
  final candidate = _addMonths(start, months);
  if (candidate.isBefore(end)) {
    return months + 1;
  }
  return months;
}

DateTime _addMonths(DateTime date, int months) {
  final totalMonths = date.month + months;
  final newYear = date.year + ((totalMonths - 1) ~/ 12);
  final newMonth = ((totalMonths - 1) % 12) + 1;
  final day = _clampDay(date.day, newYear, newMonth);
  return DateTime(newYear, newMonth, day, date.hour, date.minute, date.second, date.millisecond, date.microsecond);
}

DateTime _addYearsClamped(DateTime date, int years) {
  final newYear = date.year + years;
  final day = _clampDay(date.day, newYear, date.month);
  return DateTime(newYear, date.month, day, date.hour, date.minute, date.second, date.millisecond, date.microsecond);
}

int _clampDay(int desiredDay, int year, int month) {
  final last = _daysInMonth(year, month);
  return desiredDay > last ? last : desiredDay;
}

int _daysInMonth(int year, int month) {
  final beginningNextMonth = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
  return beginningNextMonth.subtract(const Duration(days: 1)).day;
}