import '../models/habit.dart';
import '../models/habit_completion.dart';

/// Pure, framework-agnostic streak/statistics calculations for a single
/// habit, given its full completion history. Kept separate from any
/// storage or UI concerns so it can be unit tested directly.
class HabitStats {
  final Habit habit;
  final Map<String, HabitCompletion> _completions;

  HabitStats(this.habit, Map<String, HabitCompletion> completions)
      : _completions = completions;

  HabitCompletion? completionOn(DateTime date) =>
      _completions[HabitCompletion.keyFor(habit.id, date)];

  bool isDoneOn(DateTime date) => completionOn(date)?.done ?? false;

  /// Current streak counted backwards from [today], skipping days the
  /// habit wasn't due on (so a daily habit due only on weekdays doesn't
  /// break its streak over the weekend).
  int currentStreak({DateTime? today}) {
    final now = HabitCompletion.normalize(today ?? DateTime.now());
    var streak = 0;
    var cursor = now;

    // If today is due and not yet done, start counting from yesterday
    // instead — an unfinished "today" shouldn't zero out the streak.
    if (habit.isDueOn(cursor) && !isDoneOn(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // Walk backwards indefinitely; bail out after a generous bound so a
    // habit with no history at all doesn't loop forever.
    for (var i = 0; i < 3660; i++) {
      if (!habit.isDueOn(cursor)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      if (isDoneOn(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Fraction of due days completed, over the last [days] calendar days
  /// (inclusive of today).
  double completionRate({int days = 30, DateTime? today}) {
    final now = HabitCompletion.normalize(today ?? DateTime.now());
    var due = 0;
    var done = 0;
    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      if (habit.createdAt.isAfter(date)) continue;
      if (!habit.isDueOn(date)) continue;
      due++;
      if (isDoneOn(date)) done++;
    }
    if (due == 0) return 0;
    return done / due;
  }

  /// One entry per day for the last [days] days, oldest first, for a
  /// week-dot style progress row.
  List<DayStatus> recentDays({int days = 7, DateTime? today}) {
    final now = HabitCompletion.normalize(today ?? DateTime.now());
    final result = <DayStatus>[];
    for (var i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      result.add(DayStatus(
        date: date,
        isDue: habit.isDueOn(date),
        isDone: isDoneOn(date),
      ));
    }
    return result;
  }

  /// Every day in [month] (1-12) of [year], with due/done status, for a
  /// calendar grid.
  List<DayStatus> monthDays(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(daysInMonth, (i) {
      final date = DateTime(year, month, i + 1);
      return DayStatus(
        date: date,
        isDue: habit.isDueOn(date),
        isDone: isDoneOn(date),
      );
    });
  }

  int get totalCompletions =>
      _completions.values.where((c) => c.habitId == habit.id && c.done).length;
}

class DayStatus {
  final DateTime date;
  final bool isDue;
  final bool isDone;

  const DayStatus({
    required this.date,
    required this.isDue,
    required this.isDone,
  });
}
