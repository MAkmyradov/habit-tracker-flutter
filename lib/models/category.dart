import 'package:flutter/material.dart';

/// A tag used to group habits and tasks (e.g. "Health", "Work", "Study").
class HabitCategory {
  final String id;
  String name;
  Color color;

  HabitCategory({
    required this.id,
    required this.name,
    this.color = Colors.blueGrey,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.value,
      };

  factory HabitCategory.fromJson(Map<String, dynamic> json) {
    return HabitCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
    );
  }

  static List<HabitCategory> defaults() => [
        HabitCategory(id: 'health', name: 'Health', color: Colors.green),
        HabitCategory(id: 'work', name: 'Work', color: Colors.indigo),
        HabitCategory(id: 'study', name: 'Study', color: Colors.orange),
        HabitCategory(id: 'personal', name: 'Personal', color: Colors.pink),
      ];
}
