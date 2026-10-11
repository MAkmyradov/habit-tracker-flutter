import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/app_store.dart';
import '../services/habit_stats.dart';
import '../theme/app_theme.dart';
import 'edit_habit_screen.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Shows one habit's streak, a monthly calendar of completions, and
/// summary statistics — matching the reference app's habit detail view
/// (Calendar / Statistics tabs).
class HabitDetailScreen extends StatefulWidget {
  final AppStore store;
  final Habit habit;

  const HabitDetailScreen({super.key, required this.store, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.store.statsFor(widget.habit);
    final streak = stats.currentStreak();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EditHabitScreen(
                  store: widget.store,
                  existing: widget.habit,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calendar'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CalendarTab(
            stats: stats,
            visibleMonth: _visibleMonth,
            onShiftMonth: _shiftMonth,
            streak: streak,
          ),
          _StatisticsTab(stats: stats, streak: streak),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text('"${widget.habit.name}" and its history will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await widget.store.deleteHabit(widget.habit.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  final HabitStats stats;
  final DateTime visibleMonth;
  final ValueChanged<int> onShiftMonth;
  final int streak;

  const _CalendarTab({
    required this.stats,
    required this.visibleMonth,
    required this.onShiftMonth,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final days = stats.monthDays(visibleMonth.year, visibleMonth.month);
    final leadingBlanks = (days.first.date.weekday - 1) % 7;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onShiftMonth(-1),
            ),
            Text(
              '${_monthNames[visibleMonth.month - 1]} ${visibleMonth.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onShiftMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: days.length + leadingBlanks,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = days[index - leadingBlanks];
            return _CalendarCell(day: day);
          },
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: AppTheme.accent),
                const SizedBox(width: 8),
                Text('Streak', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  '$streak days',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final DayStatus day;

  const _CalendarCell({required this.day});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (!day.isDue) {
      color = Colors.white10;
    } else if (day.isDone) {
      color = AppTheme.success;
    } else if (day.date.isBefore(DateTime.now())) {
      color = Colors.redAccent.withOpacity(0.5);
    } else {
      color = AppTheme.amber.withOpacity(0.5);
    }
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text('${day.date.day}', style: const TextStyle(fontSize: 12)),
    );
  }
}

class _StatisticsTab extends StatelessWidget {
  final HabitStats stats;
  final int streak;

  const _StatisticsTab({required this.stats, required this.streak});

  @override
  Widget build(BuildContext context) {
    final rate30 = stats.completionRate(days: 30);
    final rate7 = stats.completionRate(days: 7);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatTile(label: 'Current streak', value: '$streak days'),
        _StatTile(label: 'Total completions', value: '${stats.totalCompletions}'),
        _StatTile(
          label: 'Last 7 days',
          value: '${(rate7 * 100).round()}%',
        ),
        _StatTile(
          label: 'Last 30 days',
          value: '${(rate30 * 100).round()}%',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
