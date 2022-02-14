library flutter_calendar_dooboo;

class Week {
  final List<DateTime> days;
  final int weekNumber;

  Week(this.days, this.weekNumber);

  bool containsDay(DateTime dateTime) {
    if (days.isEmpty) return false;

    DateTime mDateTime = days.firstWhere((element) {
      return dateTime.day == element.day &&
          dateTime.month == element.month &&
          dateTime.year == element.year;
    });

    return mDateTime != null;
  }
}
