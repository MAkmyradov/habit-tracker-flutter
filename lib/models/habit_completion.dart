/// A single day's record of progress on a [Habit].
///
/// One entry per (habitId, date) pair. [value] holds the numeric amount
/// logged (seconds for timer habits, count for numeric habits, 0/1 for
/// yes/no habits) and [done] is the authoritative completion flag.
class HabitCompletion {
  final String habitId;
  final DateTime date; // normalized to midnight, local time
  bool done;
  int value;

  HabitCompletion({
    required this.habitId,
    required this.date,
    this.done = false,
    this.value = 0,
  });

  static DateTime normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String keyFor(String habitId, DateTime date) {
    final d = normalize(date);
    return '$habitId|${d.toIso8601String()}';
  }

  String get key => keyFor(habitId, date);

  Map<String, dynamic> toJson() => {
        'habitId': habitId,
        'date': date.toIso8601String(),
        'done': done,
        'value': value,
      };

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      done: json['done'] as bool,
      value: json['value'] as int,
    );
  }
}
