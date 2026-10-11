import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/task.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/date_strip.dart';
import 'habit_detail_screen.dart';

/// The "Today" tab: a date strip plus every habit and task due on the
/// selected day, with a quick-complete checkmark.
class TodayScreen extends StatefulWidget {
  final AppStore store;

  const TodayScreen({super.key, required this.store});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DateTime _selected = HabitCompletion.normalize(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final habits = widget.store.habitsDueOn(_selected);
    final tasks = widget.store.tasksDueOn(_selected);

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: Column(
        children: [
          DateStrip(
            selected: _selected,
            onSelect: (date) => setState(() => _selected = date),
          ),
          const Divider(height: 1),
          Expanded(
            child: (habits.isEmpty && tasks.isEmpty)
                ? const _EmptyDay()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...habits.map((h) => _HabitRow(
                            store: widget.store,
                            habit: h,
                            date: _selected,
                          )),
                      ...tasks.map((t) => _TaskRow(
                            store: widget.store,
                            task: t,
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text('Nothing due on this day',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final AppStore store;
  final Habit habit;
  final DateTime date;

  const _HabitRow({required this.store, required this.habit, required this.date});

  @override
  Widget build(BuildContext context) {
    final stats = store.statsFor(habit);
    final done = stats.isDoneOn(date);

    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HabitDetailScreen(store: store, habit: habit),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: habit.color.withOpacity(0.2),
          child: Icon(habit.icon, color: habit.color),
        ),
        title: Text(habit.name),
        subtitle: const Text('Habit', style: TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppTheme.success : AppTheme.textSecondary,
            size: 28,
          ),
          onPressed: () => store.toggleHabitDone(habit, date),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final AppStore store;
  final Task task;

  const _TaskRow({required this.store, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white10,
          child: Icon(
            task.isRecurring ? Icons.repeat : Icons.home_outlined,
            color: AppTheme.textSecondary,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
          ),
        ),
        subtitle: const Text('Task', style: TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: Icon(
            task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.isDone ? AppTheme.success : AppTheme.textSecondary,
            size: 28,
          ),
          onPressed: () => store.toggleTaskDone(task.id),
        ),
      ),
    );
  }
}
