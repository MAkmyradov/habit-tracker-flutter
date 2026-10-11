import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/repeat_schedule.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';

const _iconChoices = [
  Icons.check_circle_outline,
  Icons.directions_run,
  Icons.local_drink,
  Icons.menu_book,
  Icons.self_improvement,
  Icons.fitness_center,
  Icons.bedtime,
  Icons.restaurant,
  Icons.code,
  Icons.brush,
  Icons.music_note,
  Icons.savings,
];

const _colorChoices = [
  Colors.teal,
  Colors.indigo,
  Colors.pink,
  Colors.orange,
  Colors.green,
  Colors.purple,
  Colors.amber,
  Colors.cyan,
];

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Form for creating a new habit, or editing [existing] if provided.
/// Lets the user pick a name, icon/color, repeat schedule, and tracking
/// mode (yes/no, numeric target, or timer duration) — mirroring
/// HabitNow's habit-creation options.
class EditHabitScreen extends StatefulWidget {
  final AppStore store;
  final Habit? existing;

  const EditHabitScreen({super.key, required this.store, this.existing});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;

  late IconData _icon;
  late Color _color;
  late RepeatType _repeatType;
  late Set<int> _weekdays;
  late TrackingMode _trackingMode;

  @override
  void initState() {
    super.initState();
    final h = widget.existing;
    _nameController = TextEditingController(text: h?.name ?? '');
    _targetController =
        TextEditingController(text: (h?.targetValue ?? 1).toString());
    _unitController = TextEditingController(text: h?.unitLabel ?? '');
    _icon = h?.icon ?? _iconChoices.first;
    _color = h?.color ?? _colorChoices.first;
    _repeatType = h?.schedule.type ?? RepeatType.daily;
    _weekdays = {...(h?.schedule.weekdays ?? const {})};
    _trackingMode = h?.trackingMode ?? TrackingMode.yesNo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final schedule = RepeatSchedule(
      type: _repeatType,
      weekdays: _repeatType == RepeatType.monthly ? const {} : _weekdays,
    );
    final target = int.tryParse(_targetController.text) ?? 1;

    if (widget.existing != null) {
      final h = widget.existing!;
      h.name = name;
      h.icon = _icon;
      h.color = _color;
      h.schedule = schedule;
      h.trackingMode = _trackingMode;
      h.targetValue = target;
      h.unitLabel = _unitController.text.trim().isEmpty
          ? null
          : _unitController.text.trim();
      await widget.store.updateHabit(h);
    } else {
      await widget.store.addHabit(
        name: name,
        icon: _icon,
        color: _color,
        schedule: schedule,
        trackingMode: _trackingMode,
        targetValue: target,
        unitLabel: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Habit' : 'Edit Habit'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Habit name'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          Text('Icon', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _IconPicker(
            selected: _icon,
            onSelect: (icon) => setState(() => _icon = icon),
          ),
          const SizedBox(height: 20),
          Text('Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _ColorPicker(
            selected: _color,
            onSelect: (color) => setState(() => _color = color),
          ),
          const SizedBox(height: 20),
          Text('Repeats', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<RepeatType>(
            segments: const [
              ButtonSegment(value: RepeatType.daily, label: Text('Daily')),
              ButtonSegment(value: RepeatType.weekly, label: Text('Weekly')),
              ButtonSegment(value: RepeatType.monthly, label: Text('Monthly')),
            ],
            selected: {_repeatType},
            onSelectionChanged: (s) => setState(() => _repeatType = s.first),
          ),
          if (_repeatType != RepeatType.monthly) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final day = i + 1;
                final selected = _weekdays.contains(day);
                return FilterChip(
                  label: Text(_weekdayLabels[i]),
                  selected: selected,
                  onSelected: (sel) => setState(() {
                    if (sel) {
                      _weekdays.add(day);
                    } else {
                      _weekdays.remove(day);
                    }
                  }),
                );
              }),
            ),
            if (_repeatType == RepeatType.daily)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Leave all unchecked for "every day"',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
          ],
          const SizedBox(height: 20),
          Text('Tracking', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<TrackingMode>(
            segments: const [
              ButtonSegment(value: TrackingMode.yesNo, label: Text('Yes/No')),
              ButtonSegment(value: TrackingMode.numeric, label: Text('Numeric')),
              ButtonSegment(value: TrackingMode.timer, label: Text('Timer')),
            ],
            selected: {_trackingMode},
            onSelectionChanged: (s) => setState(() => _trackingMode = s.first),
          ),
          if (_trackingMode != TrackingMode.yesNo) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _trackingMode == TrackingMode.timer
                          ? 'Target (minutes)'
                          : 'Target amount',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (_trackingMode == TrackingMode.numeric)
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Unit (e.g. glasses)'),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save habit'),
          ),
        ],
      ),
    );
  }
}

class _IconPicker extends StatelessWidget {
  final IconData selected;
  final ValueChanged<IconData> onSelect;

  const _IconPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _iconChoices.map((icon) {
        final isSelected = icon == selected;
        return GestureDetector(
          onTap: () => onSelect(icon),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: isSelected ? AppTheme.accent : Colors.white10,
            child: Icon(icon, color: Colors.white),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _ColorPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: _colorChoices.map((color) {
        final isSelected = color.value == selected.value;
        return GestureDetector(
          onTap: () => onSelect(color),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
