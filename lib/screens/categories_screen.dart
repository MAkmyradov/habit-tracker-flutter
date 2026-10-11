import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../services/app_store.dart';

const _uuid = Uuid();

const _paletteChoices = [
  Colors.green,
  Colors.indigo,
  Colors.orange,
  Colors.pink,
  Colors.teal,
  Colors.purple,
  Colors.amber,
  Colors.cyan,
];

/// The "Categories" tab: lets the user group habits/tasks (Health, Work,
/// Study, ...) and shows how many habits use each one.
class CategoriesScreen extends StatelessWidget {
  final AppStore store;

  const CategoriesScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final categories = store.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final habitCount =
              store.habits.where((h) => h.categoryId == category.id).length;
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: category.color),
              title: Text(category.name),
              subtitle: Text(
                '$habitCount habit${habitCount == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => store.deleteCategory(category.id),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    Color selected = _paletteChoices.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _paletteChoices.map((color) {
                  final isSelected = color.value == selected.value;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selected = color),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: color,
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                store.addCategory(
                  HabitCategory(id: _uuid.v4(), name: name, color: selected),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
