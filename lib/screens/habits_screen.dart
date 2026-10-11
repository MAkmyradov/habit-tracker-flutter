import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/repeat_schedule.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/streak_badge.dart';
import '../widgets/week_dots.dart';
import 'edit_habit_screen.dart';
import 'habit_detail_screen.dart';

/// The "Habits" tab: a card per habit with its streak, completion rate,
/// and last-7-days dot row, matching the reference app's Habits list.
class HabitsScreen extends StatelessWidget {
  final AppStore store;

  const HabitsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final habits = store.habits;

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EditHabitScreen(store: store)),
        ),
        child: const Icon(Icons.add),
      ),
      body: habits.isEmpty
          ? Center(
              child: Text(
                'No habits yet.\nTap + to create your first one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: habits.length,
              itemBuilder: (context, index) => _HabitCard(
                store: store,
                habit: habits[index],
              ),
            ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final AppStore store;
  final Habit habit;

  const _HabitCard({required this.store, required this.habit});

  @override
  Widget build(BuildContext context) {
    final stats = store.statsFor(habit);
    final streak = stats.currentStreak();
    final rate = stats.completionRate();
    final week = stats.recentDays(days: 7);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HabitDetailScreen(store: store, habit: habit),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: habit.color.withOpacity(0.2),
                    child: Icon(habit.icon, color: habit.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          _scheduleLabel(habit),
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StreakBadge(streak: streak),
                ],
              ),
              const SizedBox(height: 16),
              WeekDots(days: week),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.show_chart, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${(rate * 100).round()}% completion',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _scheduleLabel(Habit habit) {
    switch (habit.schedule.type) {
      case RepeatType.daily:
        return habit.schedule.weekdays.isEmpty ? 'Every day' : 'Daily (custom days)';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
    }
  }
}
