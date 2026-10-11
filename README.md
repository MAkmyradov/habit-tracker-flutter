# Habit Tracker

A Flutter habit and task tracker inspired by
[HabitNow](https://play.google.com/store/apps/details?id=com.habitnow) —
daily/weekly/monthly habits, yes/no/numeric/timer tracking, streaks,
calendar + statistics views, basic task management, and categories.

Built by [Merdan Akmyradov](https://github.com/MAkmyradov).

## Features

- **Today tab** — a horizontal date strip with every habit and task due
  that day, one-tap complete
- **Habits tab** — streak badge, last-7-days dot row, and rolling
  completion rate per habit
- **Habit detail** — Calendar view (month grid colored by completion) and
  Statistics view (streak, total completions, 7/30-day rates)
- **Flexible scheduling** — daily (every day or specific weekdays),
  weekly (specific weekdays), or monthly (specific days of month)
- **Three tracking modes** — Yes/No, Numeric (e.g. "8 glasses of water"),
  and Timer (e.g. "meditate 10 min", run from the Timer tab)
- **Tasks tab** — simple one-off and recurring to-dos, no streak tracking
  (matching HabitNow's "basic" task list)
- **Categories tab** — group habits by Health / Work / Study / Personal,
  or your own custom categories
- **Dark theme** — near-black background with a pink/red accent, modeled
  on the reference screenshots
- **Offline-first** — everything persists on-device via
  `shared_preferences`, no account or network required

## Architecture

```
lib/
  models/
    habit.dart             # Habit: name, icon, color, schedule, tracking mode
    habit_completion.dart  # one record per (habit, date): done + numeric value
    repeat_schedule.dart   # daily/weekly/monthly due-date logic
    task.dart               # one-off or recurring to-do (no streak)
    category.dart           # habit/task grouping tag
  services/
    habit_repository.dart  # SharedPreferences-backed JSON persistence
    habit_stats.dart       # pure streak/completion-rate/calendar logic
                            # (framework-agnostic, unit tested)
    app_store.dart          # in-memory ChangeNotifier state + mutations
  theme/app_theme.dart      # dark theme matching the reference app
  widgets/
    date_strip.dart         # Today tab's horizontal date picker
    streak_badge.dart       # flame + streak-count badge
    week_dots.dart          # 7-day colored dot row
  screens/
    today_screen.dart
    habits_screen.dart
    edit_habit_screen.dart  # create/edit form
    habit_detail_screen.dart # Calendar + Statistics tabs
    tasks_screen.dart
    categories_screen.dart
    timer_screen.dart
  main.dart                 # bottom-nav shell tying the 5 tabs together
test/
  habit_stats_test.dart     # streak + completion-rate unit tests
```

The streak/statistics engine (`lib/services/habit_stats.dart`) is kept
completely separate from Flutter widgets and from storage, so its logic
— which days count as "due," how a streak survives a non-due day, how
completion rate is windowed — is unit tested directly without needing a
widget test harness.

## How streaks work

A habit's `RepeatSchedule` decides which days it's "due" on (every day,
specific weekdays, or specific days of the month). The streak counter
walks backward from today, skipping any day the habit wasn't due, and
stops at the first due day that wasn't completed. If today is still due
and not yet completed, it's excluded from the count rather than zeroing
the whole streak — so you don't lose your streak just by checking the
app before finishing today's habit.

## Running it

This repo ships the Dart/Flutter source only — platform folders
(`android/`, `ios/`, etc.) are generated locally and left out of version
control.

```bash
flutter create .     # generates the platform folders for this project
flutter pub get
flutter test          # run the streak/stats unit tests
flutter run            # launch on a connected device/emulator
```

## Roadmap ideas

- [ ] Local notifications for habit reminders (the data model already
      has `reminderEnabled` / `reminderTime` on `Habit`)
- [ ] Home-screen widgets showing today's remaining habits
- [ ] Sub-task checklists per habit
- [ ] Export/import data as JSON
- [ ] Cloud sync
