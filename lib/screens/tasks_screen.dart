import 'package:flutter/material.dart';
import '../models/repeat_schedule.dart';
import '../models/task.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';

/// The "Tasks" tab: simple one-off and recurring to-dos, unlike habits
/// these carry no streak — matching HabitNow's "basic" task list.
class TasksScreen extends StatelessWidget {
  final AppStore store;

  const TasksScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final tasks = [...store.tasks]
      ..sort((a, b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        return a.createdAt.compareTo(b.createdAt);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'No tasks yet.\nTap + to add a one-off or recurring to-do.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: task.isDone ? AppTheme.success : AppTheme.textSecondary,
                      ),
                      onPressed: () => store.toggleTaskDone(task.id),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                        color:
                            task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      task.isRecurring
                          ? 'Recurring'
                          : (task.dueDate != null
                              ? 'Due ${task.dueDate!.month}/${task.dueDate!.day}'
                              : 'No due date'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => store.deleteTask(task.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    bool recurring = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New Task', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'What do you need to do?'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Repeats every day'),
                  value: recurring,
                  onChanged: (v) => setSheetState(() => recurring = v),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    await store.addTask(
                      title: title,
                      dueDate: recurring ? null : DateTime.now(),
                      schedule: recurring ? RepeatSchedule.everyDay() : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Add task'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
