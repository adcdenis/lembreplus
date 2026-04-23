enum Recurrence {
  none,
  every6Hours,
  every12Hours,
  daily,
  weekly,
  monthly,
  yearly;

  static Recurrence fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'every6hours':
        return Recurrence.every6Hours;
      case 'every12hours':
        return Recurrence.every12Hours;
      case 'daily':
        return Recurrence.daily;
      case 'weekly':
        return Recurrence.weekly;
      case 'monthly':
        return Recurrence.monthly;
      case 'yearly':
        return Recurrence.yearly;
      default:
        return Recurrence.none;
    }
  }
}

enum RecurrenceUnit { hours, days, years }

class RecurrenceDefinition {
  final Recurrence recurrence;
  final int? count;
  final RecurrenceUnit? unit;

  const RecurrenceDefinition({
    required this.recurrence,
    this.count,
    this.unit,
  });

  bool get isCustom => count != null && unit != null;
  bool get isNone => recurrence == Recurrence.none && !isCustom;

  String get label {
    if (isNone) return 'Nenhuma';
    if (isCustom) {
      final unitLabel = switch (unit!) {
        RecurrenceUnit.hours => count == 1 ? 'hora' : 'horas',
        RecurrenceUnit.days => count == 1 ? 'dia' : 'dias',
        RecurrenceUnit.years => count == 1 ? 'ano' : 'anos',
      };
      return '$count $unitLabel';
    }

    switch (recurrence) {
      case Recurrence.none:
        return 'Nenhuma';
      case Recurrence.every6Hours:
        return '6 horas';
      case Recurrence.every12Hours:
        return '12 horas';
      case Recurrence.daily:
        return 'Diário';
      case Recurrence.weekly:
        return 'Semanal';
      case Recurrence.monthly:
        return 'Mensal';
      case Recurrence.yearly:
        return 'Anual';
    }
  }

  String get storageValue {
    if (isCustom) {
      return '$count ${unit!.name}';
    }
    return recurrence.name;
  }

  static RecurrenceDefinition parse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const RecurrenceDefinition(recurrence: Recurrence.none);
    }

    final normalized = value.trim();
    final fixed = Recurrence.fromString(normalized);
    if (fixed != Recurrence.none || normalized.toLowerCase() == 'none') {
      return RecurrenceDefinition(recurrence: fixed);
    }

    final match = RegExp(
      r'^(\d+)\s*(hours?|days?|years?|hour|day|year)$',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (match != null) {
      final count = int.tryParse(match.group(1)!);
      final rawUnit = match.group(2)!.toLowerCase();
      final unit = switch (rawUnit) {
        'hour' || 'hours' => RecurrenceUnit.hours,
        'day' || 'days' => RecurrenceUnit.days,
        'year' || 'years' => RecurrenceUnit.years,
        _ => null,
      };
      if (count != null && count > 0 && unit != null) {
        return RecurrenceDefinition(
          recurrence: Recurrence.none,
          count: count,
          unit: unit,
        );
      }
    }

    return const RecurrenceDefinition(recurrence: Recurrence.none);
  }
}
