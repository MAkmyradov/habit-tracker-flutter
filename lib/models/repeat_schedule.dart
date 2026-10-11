/// How often a habit repeats.
enum RepeatType { daily, weekly, monthly }

/// Defines which days a habit is "due" on.
///
/// - [RepeatType.daily]: due every day, or only on the weekdays listed in
///   [weekdays] (1 = Monday ... 7 = Sunday) if that set is non-empty.
/// - [RepeatType.weekly]: due once on whichever weekday(s) are listed in
///   [weekdays].
/// - [RepeatType.monthly]: due on the day-of-month values in [monthDays]
///   (1-31).
class RepeatSchedule {
  final RepeatType type;
  final Set<int> weekdays; // 1=Mon .. 7=Sun, used by daily/weekly
  final Set<int> monthDays; // 1..31, used by monthly

  const RepeatSchedule({
    required this.type,
    this.weekdays = const {},
    this.monthDays = const {},
  });

  factory RepeatSchedule.everyDay() =>
      const RepeatSchedule(type: RepeatType.daily);

  bool isDueOn(DateTime date) {
    switch (type) {
      case RepeatType.daily:
        return weekdays.isEmpty || weekdays.contains(date.weekday);
      case RepeatType.weekly:
        return weekdays.contains(date.weekday);
      case RepeatType.monthly:
        return monthDays.contains(date.day);
    }
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'weekdays': weekdays.toList(),
        'monthDays': monthDays.toList(),
      };

  factory RepeatSchedule.fromJson(Map<String, dynamic> json) {
    return RepeatSchedule(
      type: RepeatType.values.byName(json['type'] as String),
      weekdays: ((json['weekdays'] as List<dynamic>?) ?? [])
          .map((e) => e as int)
          .toSet(),
      monthDays: ((json['monthDays'] as List<dynamic>?) ?? [])
          .map((e) => e as int)
          .toSet(),
    );
  }
}
