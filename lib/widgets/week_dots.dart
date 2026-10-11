import 'package:flutter/material.dart';
import '../services/habit_stats.dart';
import '../theme/app_theme.dart';

/// A row of small day badges (e.g. "9 10 11 12 13 14 15") colored by
/// status, matching the Habits-tab week row in the reference app.
class WeekDots extends StatelessWidget {
  final List<DayStatus> days;

  const WeekDots({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) => _DayDot(day: d)).toList(),
    );
  }
}

class _DayDot extends StatelessWidget {
  final DayStatus day;

  const _DayDot({required this.day});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = day.date.year == today.year &&
        day.date.month == today.month &&
        day.date.day == today.day;

    Color bg;
    Color fg = Colors.white;
    if (!day.isDue) {
      bg = Colors.white10;
      fg = AppTheme.textSecondary;
    } else if (day.isDone) {
      bg = AppTheme.success;
    } else if (day.date.isBefore(DateTime(today.year, today.month, today.day))) {
      bg = Colors.redAccent.withOpacity(0.6);
    } else {
      bg = AppTheme.amber;
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: Colors.white, width: 1.5) : null,
      ),
      child: Text(
        '${day.date.day}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
