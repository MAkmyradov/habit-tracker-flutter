import 'package:flutter/material.dart';
import 'screens/categories_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/today_screen.dart';
import 'services/app_store.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  final AppStore _store = AppStore();
  late final Future<void> _init;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _init = _store.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ListenableBuilder(
          listenable: _store,
          builder: (context, _) {
            final screens = [
              TodayScreen(store: _store),
              HabitsScreen(store: _store),
              TasksScreen(store: _store),
              CategoriesScreen(store: _store),
              TimerScreen(store: _store),
            ];

            return Scaffold(
              body: IndexedStack(index: _tabIndex, children: screens),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _tabIndex,
                onTap: (index) => setState(() => _tabIndex = index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    label: 'Today',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.self_improvement),
                    label: 'Habits',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_outlined),
                    label: 'Categories',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.timer_outlined),
                    label: 'Timer',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
