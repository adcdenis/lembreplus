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
