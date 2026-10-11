import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Horizontal scrollable strip of dates around [selected], matching the
/// "Today" tab's calendar strip in the reference app.
class DateStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const DateStrip({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 4));
    final dates = List.generate(14, (i) => start.add(Duration(days: i)));

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _sameDay(date, selected);
          return GestureDetector(
            onTap: () => onSelect(date),
            child: Container(
              width: 48,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLabels[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
