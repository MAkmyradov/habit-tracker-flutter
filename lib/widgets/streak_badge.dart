import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small flame-and-number badge showing a habit's current streak.
class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final active = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppTheme.accent.withOpacity(0.15) : Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: active ? AppTheme.accent : AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? AppTheme.accent : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
