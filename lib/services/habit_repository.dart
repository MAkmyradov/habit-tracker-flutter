import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/task.dart';

/// Persists all app data (habits, tasks, categories, completions) to
/// on-device storage via [SharedPreferences], serialized as JSON.
///
/// This is intentionally a thin, synchronous-feeling wrapper so the UI
/// layer and the stats engine never need to know about storage details.
class HabitRepository {
  static const _habitsKey = 'habit_tracker_habits_v1';
  static const _tasksKey = 'habit_tracker_tasks_v1';
  static const _categoriesKey = 'habit_tracker_categories_v1';
  static const _completionsKey = 'habit_tracker_completions_v1';

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_habitsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Habit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _habitsKey,
      jsonEncode(habits.map((h) => h.toJson()).toList()),
    );
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<List<HabitCategory>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_categoriesKey);
    if (raw == null) return HabitCategory.defaults();
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HabitCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<HabitCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _categoriesKey,
      jsonEncode(categories.map((c) => c.toJson()).toList()),
    );
  }

  Future<Map<String, HabitCompletion>> loadCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completionsKey);
    if (raw == null) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    final map = <String, HabitCompletion>{};
    for (final entry in list) {
      final completion =
          HabitCompletion.fromJson(entry as Map<String, dynamic>);
      map[completion.key] = completion;
    }
    return map;
  }

  Future<void> saveCompletions(Map<String, HabitCompletion> completions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _completionsKey,
      jsonEncode(completions.values.map((c) => c.toJson()).toList()),
    );
  }
}
