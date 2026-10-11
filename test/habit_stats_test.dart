import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/models/habit_completion.dart';
import 'package:habit_tracker/models/repeat_schedule.dart';
import 'package:habit_tracker/services/habit_stats.dart';

Habit _dailyHabit({DateTime? createdAt}) => Habit(
      id: 'h1',
      name: 'Drink water',
      schedule: RepeatSchedule.everyDay(),
      createdAt: createdAt,
    );

Map<String, HabitCompletion> _completionsFor(
  String habitId,
  List<DateTime> doneDates,
) {
  final map = <String, HabitCompletion>{};
  for (final date in doneDates) {
    final normalized = HabitCompletion.normalize(date);
    final completion =
        HabitCompletion(habitId: habitId, date: normalized, done: true, value: 1);
    map[completion.key] = completion;
  }
  return map;
}

void main() {
  group('RepeatSchedule', () {
    test('daily with no weekday restriction is due every day', () {
      final schedule = RepeatSchedule.everyDay();
      expect(schedule.isDueOn(DateTime(2026, 10, 11)), isTrue); // Sunday
      expect(schedule.isDueOn(DateTime(2026, 10, 13)), isTrue); // Tuesday
    });

    test('weekly is due only on listed weekdays', () {
      final schedule = RepeatSchedule(type: RepeatType.weekly, weekdays: {1, 3}); // Mon, Wed
      expect(schedule.isDueOn(DateTime(2026, 10, 12)), isTrue); // Monday
      expect(schedule.isDueOn(DateTime(2026, 10, 13)), isFalse); // Tuesday
      expect(schedule.isDueOn(DateTime(2026, 10, 14)), isTrue); // Wednesday
    });

    test('monthly is due only on listed days of month', () {
      final schedule = RepeatSchedule(type: RepeatType.monthly, monthDays: {1, 15});
      expect(schedule.isDueOn(DateTime(2026, 10, 1)), isTrue);
      expect(schedule.isDueOn(DateTime(2026, 10, 15)), isTrue);
      expect(schedule.isDueOn(DateTime(2026, 10, 16)), isFalse);
    });
  });

  group('HabitStats.currentStreak', () {
    test('is zero with no completions', () {
      final habit = _dailyHabit(createdAt: DateTime(2026, 9, 1));
      final stats = HabitStats(habit, {});
      expect(stats.currentStreak(today: DateTime(2026, 10, 11)), 0);
    });

    test('counts consecutive completed days ending yesterday if today is pending', () {
      final habit = _dailyHabit(createdAt: DateTime(2026, 10, 1));
      final today = DateTime(2026, 10, 11);
      final completions = _completionsFor('h1', [
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 9),
        DateTime(2026, 10, 8),
      ]);
      final stats = HabitStats(habit, completions);
      expect(stats.currentStreak(today: today), 3);
    });

    test('includes today when already completed', () {
      final habit = _dailyHabit(createdAt: DateTime(2026, 10, 1));
      final today = DateTime(2026, 10, 11);
      final completions = _completionsFor('h1', [
        DateTime(2026, 10, 11),
        DateTime(2026, 10, 10),
      ]);
      final stats = HabitStats(habit, completions);
      expect(stats.currentStreak(today: today), 2);
    });

    test('breaks on a missed due day', () {
      final habit = _dailyHabit(createdAt: DateTime(2026, 10, 1));
      final today = DateTime(2026, 10, 11);
      // Missing Oct 9 breaks the streak before it.
      final completions = _completionsFor('h1', [
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 8),
        DateTime(2026, 10, 7),
      ]);
      final stats = HabitStats(habit, completions);
      expect(stats.currentStreak(today: today), 1);
    });

    test('skips days the habit is not due on (weekday-only habit)', () {
      final habit = Habit(
        id: 'h2',
        name: 'Gym',
        schedule: RepeatSchedule(type: RepeatType.daily, weekdays: {1, 2, 3, 4, 5}),
        createdAt: DateTime(2026, 10, 1),
      );
      // Oct 12 2026 is a Monday. Fri 9, skip weekend, Mon 12 all done.
      final today = DateTime(2026, 10, 12);
      final completions = _completionsFor('h2', [
        DateTime(2026, 10, 12), // Mon
        DateTime(2026, 10, 9), // Fri
        DateTime(2026, 10, 8), // Thu
      ]);
      final stats = HabitStats(habit, completions);
      expect(stats.currentStreak(today: today), 3);
    });
  });

  group('HabitStats.completionRate', () {
    test('is 0 when nothing has been done', () {
      final habit = _dailyHabit(createdAt: DateTime(2026, 10, 1));
      final stats = HabitStats(habit, {});
      expect(stats.completionRate(days: 10, today: DateTime(2026, 10, 11)), 0);
    });

    test('is 1.0 when every due day since creation was completed', () {
      final habit = _dailyHabit(createdAt: DateTime(2026, 10, 9));
      final today = DateTime(2026, 10, 11);
      final completions = _completionsFor('h1', [
        DateTime(2026, 10, 9),
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 11),
      ]);
      final stats = HabitStats(habit, completions);
      expect(stats.completionRate(days: 10, today: today), 1.0);
    });

    test('ignores days before the habit was created', () {
      final habit = _dailyHabit(createdAt: DateTime(2026, 10, 10));
      final today = DateTime(2026, 10, 11);
      final completions = _completionsFor('h1', [DateTime(2026, 10, 11)]);
      final stats = HabitStats(habit, completions);
      // Only Oct 10 and 11 count as "due" (habit didn't exist before), one of
      // two completed => 0.5.
      expect(stats.completionRate(days: 30, today: today), 0.5);
    });
  });
}
