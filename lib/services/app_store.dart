import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/repeat_schedule.dart';
import '../models/task.dart';
import 'habit_repository.dart';
import 'habit_stats.dart';

const _uuid = Uuid();

/// Central, in-memory app state. Loads everything from [HabitRepository]
/// on [initialize] and persists on every mutation. UI widgets listen to
/// this via [ChangeNotifier] (see main.dart's ListenableBuilder usage).
class AppStore extends ChangeNotifier {
  final HabitRepository _repository;

  List<Habit> _habits = [];
  List<Task> _tasks = [];
  List<HabitCategory> _categories = [];
  Map<String, HabitCompletion> _completions = {};

  AppStore({HabitRepository? repository})
      : _repository = repository ?? HabitRepository();

  List<Habit> get habits => List.unmodifiable(_habits);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<HabitCategory> get categories => List.unmodifiable(_categories);

  Future<void> initialize() async {
    _habits = await _repository.loadHabits();
    _tasks = await _repository.loadTasks();
    _categories = await _repository.loadCategories();
    _completions = await _repository.loadCompletions();
    notifyListeners();
  }

  HabitStats statsFor(Habit habit) => HabitStats(habit, _completions);

  List<Habit> habitsDueOn(DateTime date) =>
      _habits.where((h) => h.isDueOn(date)).toList();

  List<Task> tasksDueOn(DateTime date) {
    final normalized = HabitCompletion.normalize(date);
    return _tasks.where((t) {
      if (t.isRecurring) return t.schedule!.isDueOn(normalized);
      if (t.dueDate == null) return false;
      return HabitCompletion.normalize(t.dueDate!) == normalized;
    }).toList();
  }

  // --- Habits ---------------------------------------------------------

  Future<Habit> addHabit({
    required String name,
    String? description,
    required IconData icon,
    required Color color,
    required RepeatSchedule schedule,
    TrackingMode? trackingMode,
    int targetValue = 1,
    String? unitLabel,
    String? categoryId,
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      name: name,
      description: description,
      icon: icon,
      color: color,
      schedule: schedule,
      trackingMode: trackingMode ?? TrackingMode.yesNo,
      targetValue: targetValue,
      unitLabel: unitLabel,
      categoryId: categoryId,
    );
    _habits.add(habit);
    await _repository.saveHabits(_habits);
    notifyListeners();
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) return;
    _habits[index] = habit;
    await _repository.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    _completions.removeWhere((_, c) => c.habitId == habitId);
    await _repository.saveHabits(_habits);
    await _repository.saveCompletions(_completions);
    notifyListeners();
  }

  /// Toggles a yes/no habit's completion for [date], or sets a numeric
  /// progress value via [value] for numeric/timer habits.
  Future<void> setCompletion(
    Habit habit,
    DateTime date, {
    bool? done,
    int? value,
  }) async {
    final normalized = HabitCompletion.normalize(date);
    final key = HabitCompletion.keyFor(habit.id, normalized);
    final existing = _completions[key] ??
        HabitCompletion(habitId: habit.id, date: normalized);

    if (value != null) {
      existing.value = value;
      existing.done = existing.value >= habit.targetValue;
    } else if (done != null) {
      existing.done = done;
      existing.value = done ? habit.targetValue : 0;
    }

    _completions[key] = existing;
    await _repository.saveCompletions(_completions);
    notifyListeners();
  }

  Future<void> toggleHabitDone(Habit habit, DateTime date) async {
    final current = statsFor(habit).isDoneOn(date);
    await setCompletion(habit, date, done: !current);
  }

  // --- Tasks ------------------------------------------------------------

  Future<Task> addTask({
    required String title,
    String? notes,
    DateTime? dueDate,
    RepeatSchedule? schedule,
    String? categoryId,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      notes: notes,
      dueDate: dueDate,
      schedule: schedule,
      categoryId: categoryId,
    );
    _tasks.add(task);
    await _repository.saveTasks(_tasks);
    notifyListeners();
    return task;
  }

  Future<void> toggleTaskDone(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.isDone = !task.isDone;
    await _repository.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _repository.saveTasks(_tasks);
    notifyListeners();
  }

  // --- Categories ---------------------------------------------------------

  Future<void> addCategory(HabitCategory category) async {
    _categories.add(category);
    await _repository.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
    await _repository.saveCategories(_categories);
    notifyListeners();
  }
}
