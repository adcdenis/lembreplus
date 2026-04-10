enum Recurrence {
  none,
  daily,
  weekly,
  monthly,
  yearly;

  static Recurrence fromString(String? value) {
    switch (value?.toLowerCase()) {
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
