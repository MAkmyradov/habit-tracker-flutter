import 'package:flutter/material.dart';
import 'repeat_schedule.dart';

/// How a single day's completion of a habit is recorded.
enum TrackingMode {
  /// Simple done / not done.
  yesNo,

  /// A numeric target (e.g. "drink 8 glasses of water").
  numeric,

  /// A duration tracked with the built-in timer (e.g. "meditate 10 min").
  timer,
}

/// A recurring habit the user is trying to build.
class Habit {
  final String id;
  String name;
  String? description;
  IconData icon;
  Color color;
  RepeatSchedule schedule;
  TrackingMode trackingMode;

  /// Target for numeric tracking (e.g. 8 glasses) or timer tracking
  /// (seconds), ignored for yesNo.
  int targetValue;
  String? unitLabel; // e.g. "glasses", "pages", "min"

  bool reminderEnabled;
  TimeOfDay? reminderTime;

  final DateTime createdAt;
  String? categoryId;

  Habit({
    required this.id,
    required this.name,
    this.description,
    this.icon = Icons.check_circle_outline,
    this.color = Colors.teal,
    required this.schedule,
    this.trackingMode = TrackingMode.yesNo,
    this.targetValue = 1,
    this.unitLabel,
    this.reminderEnabled = false,
    this.reminderTime,
    DateTime? createdAt,
    this.categoryId,
  }) : createdAt = createdAt ?? DateTime.now();

  bool isDueOn(DateTime date) => schedule.isDueOn(date);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon.codePoint,
        'color': color.value,
        'schedule': schedule.toJson(),
        'trackingMode': trackingMode.name,
        'targetValue': targetValue,
        'unitLabel': unitLabel,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderTime?.hour,
        'reminderMinute': reminderTime?.minute,
        'createdAt': createdAt.toIso8601String(),
        'categoryId': categoryId,
      };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final hour = json['reminderHour'] as int?;
    final minute = json['reminderMinute'] as int?;
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      schedule:
          RepeatSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
      trackingMode: TrackingMode.values.byName(json['trackingMode'] as String),
      targetValue: json['targetValue'] as int,
      unitLabel: json['unitLabel'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTime: (hour != null && minute != null)
          ? TimeOfDay(hour: hour, minute: minute)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      categoryId: json['categoryId'] as String?,
    );
  }
}
