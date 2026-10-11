import 'repeat_schedule.dart';

/// A to-do item. Unlike a [Habit], tasks are not streak-tracked.
///
/// - A one-off task has [schedule] == null and a single [dueDate].
/// - A recurring task has a [schedule] and reappears on its due days,
///   but (per HabitNow's model) recurring tasks are just reminders —
///   completing one instance doesn't build a streak.
class Task {
  final String id;
  String title;
  String? notes;
  bool isDone;
  DateTime? dueDate;
  RepeatSchedule? schedule;
  String? categoryId;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.notes,
    this.isDone = false,
    this.dueDate,
    this.schedule,
    this.categoryId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isRecurring => schedule != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'isDone': isDone,
        'dueDate': dueDate?.toIso8601String(),
        'schedule': schedule?.toJson(),
        'categoryId': categoryId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      isDone: json['isDone'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      schedule: json['schedule'] != null
          ? RepeatSchedule.fromJson(json['schedule'] as Map<String, dynamic>)
          : null,
      categoryId: json['categoryId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
