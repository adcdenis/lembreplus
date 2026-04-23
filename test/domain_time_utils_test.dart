import 'package:flutter_test/flutter_test.dart';
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/domain/time_utils.dart';

void main() {
  group('timeToEvent & isPast', () {
    test('future event returns positive duration', () {
      final now = DateTime(2025, 01, 01, 12, 0);
      final event = DateTime(2025, 01, 02, 12, 0);
      final d = timeToEvent(event, now: now);
      expect(d.inDays, 1);
      expect(isPast(event, now: now), false);
    });

    test('past event returns negative duration', () {
      final now = DateTime(2025, 01, 02, 12, 0);
      final event = DateTime(2025, 01, 01, 12, 0);
      final d = timeToEvent(event, now: now);
      expect(d.inDays, -1);
      expect(isPast(event, now: now), true);
    });
  });

  group('nextRecurringDate', () {
    test('6-hour recurrence advances to next 6-hour slot when past', () {
      final base = DateTime(2025, 01, 01, 0, 0);
      final now = DateTime(2025, 01, 01, 7, 0);
      final nextDate = nextRecurringDate(base, Recurrence.every6Hours, now);
      expect(nextDate, DateTime(2025, 01, 01, 12, 0));
    });

    test('12-hour recurrence advances to next 12-hour slot when past', () {
      final base = DateTime(2025, 01, 01, 8, 0);
      final now = DateTime(2025, 01, 02, 1, 0);
      final nextDate = nextRecurringDate(base, Recurrence.every12Hours, now);
      expect(nextDate, DateTime(2025, 01, 02, 8, 0));
    });

    test('weekly recurrence advances to next week when past', () {
      final base = DateTime(2025, 01, 01, 10, 0);
      final now = DateTime(2025, 01, 10, 9, 0);
      final nextDate = nextRecurringDate(base, Recurrence.weekly, now);
      expect(nextDate, DateTime(2025, 01, 15, 10, 0));
    });

    test('monthly recurrence clamps day (Jan 31 -> Feb 28 non-leap)', () {
      final base = DateTime(2025, 01, 31, 10, 0);
      final now = DateTime(2025, 02, 01, 9, 0);
      final nextDate = nextRecurringDate(base, Recurrence.monthly, now);
      expect(nextDate, DateTime(2025, 02, 28, 10, 0));
    });

    test('yearly recurrence next year when date passed', () {
      final base = DateTime(2024, 03, 10, 8, 30);
      final now = DateTime(2025, 03, 11, 8, 30);
      final nextDate = nextRecurringDate(base, Recurrence.yearly, now);
      expect(nextDate, DateTime(2026, 03, 10, 8, 30));
    });
  });

  group('nextRecurringDateFromString', () {
    test('custom hourly recurrence advances to next interval when past', () {
      final base = DateTime(2025, 01, 01, 8, 0);
      final now = DateTime(2025, 01, 01, 11, 1);
      final nextDate = nextRecurringDateFromString(base, '3 hours', now);
      expect(nextDate, DateTime(2025, 01, 01, 14, 0));
    });

    test('custom daily recurrence advances correctly', () {
      final base = DateTime(2025, 01, 01, 10, 0);
      final now = DateTime(2025, 01, 05, 9, 0);
      final nextDate = nextRecurringDateFromString(base, '2 days', now);
      expect(nextDate, DateTime(2025, 01, 05, 10, 0));
    });

    test('custom yearly recurrence advances by multiple years', () {
      final base = DateTime(2024, 03, 10, 8, 30);
      final now = DateTime(2026, 03, 11, 8, 30);
      final nextDate = nextRecurringDateFromString(base, '2 years', now);
      expect(nextDate, DateTime(2028, 03, 10, 8, 30));
    });

    test('invalid recurrence returns base date', () {
      final base = DateTime(2025, 01, 01, 10, 0);
      final now = DateTime(2025, 01, 02, 10, 0);
      final nextDate = nextRecurringDateFromString(base, 'unknown', now);
      expect(nextDate, base);
    });
  });
}
