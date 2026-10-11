import 'dart:async';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';

/// The "Timer" tab: runs a countdown for a timer-tracked habit (e.g.
/// "Meditate 10 min") and logs the habit as done when the countdown
/// finishes, matching HabitNow's built-in timer tracking mode.
class TimerScreen extends StatefulWidget {
  final AppStore store;

  const TimerScreen({super.key, required this.store});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Habit? _selected;
  Timer? _ticker;
  int _remainingSeconds = 0;
  bool _running = false;

  List<Habit> get _timerHabits =>
      widget.store.habits.where((h) => h.trackingMode == TrackingMode.timer).toList();

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _selectHabit(Habit habit) {
    setState(() {
      _selected = habit;
      _remainingSeconds = habit.targetValue * 60;
      _running = false;
    });
    _ticker?.cancel();
  }

  void _toggleRunning() {
    if (_selected == null) return;
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
      return;
    }

    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _running = false;
          _complete();
        }
      });
    });
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _remainingSeconds = (_selected?.targetValue ?? 0) * 60;
    });
  }

  Future<void> _complete() async {
    final habit = _selected;
    if (habit == null) return;
    await widget.store.setCompletion(habit, DateTime.now(), done: true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${habit.name} marked complete!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _timerHabits;

    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: habits.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No timer habits yet.\nCreate a habit with Tracking set to '
                  '"Timer" to use this tab.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    children: habits.map((h) {
                      final isSelected = _selected?.id == h.id;
                      return ChoiceChip(
                        label: Text(h.name),
                        selected: isSelected,
                        onSelected: (_) => _selectHabit(h),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _selected == null
                      ? Center(
                          child: Text(
                            'Pick a habit above to start its timer',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : _TimerDial(
                          remainingSeconds: _remainingSeconds,
                          totalSeconds: _selected!.targetValue * 60,
                          running: _running,
                          onToggle: _toggleRunning,
                          onReset: _reset,
                        ),
                ),
              ],
            ),
    );
  }
}

class _TimerDial extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool running;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  const _TimerDial({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.running,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : 1 - (remainingSeconds / totalSeconds);
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 10,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                  ),
                ),
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.replay),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onToggle,
                icon: Icon(running ? Icons.pause : Icons.play_arrow),
                label: Text(running ? 'Pause' : 'Start'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
