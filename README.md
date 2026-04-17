````md
# DailyTracker

DailyTracker is a Flutter app we made to help with tracking mood and daily goals in a simple way.

The goal of the app was to make daily tracking feel easy and not like extra work. The user can log their mood, add goals, update progress, and look back at older entries.

## Features

- track daily mood
- add and manage goals
- update goal progress
- keep daily logs
- view streaks and recap stats
- check previous entries
- dark mode

## Screens

### Home
This is the main screen of the app. It shows the date, mood choices, and current goals. The user can also update goal progress from here.

### Log
This page shows older entries so the user can look back at previous days.

### Add Goal
This is where the user creates a new goal and sets its details.

### Recap
This page gives a summary of progress, streaks, and general activity.

### Settings
This page includes dark mode and the option to clear saved data.

## Tech Stack

- Flutter
- Dart
- Provider
- Shared Preferences
- Intl
- Google Fonts

## How Data Works

The app stores data locally using Shared Preferences, so it works offline and does not need a backend in this version.

## Getting Started

Make sure Flutter is installed, then run:

```bash
git clone https://github.com/raghadasslany/DailyTracker.git
cd DailyTracker
flutter pub get
flutter run
````

## Project Structure

```text
lib/
├── main.dart
├── models/
├── providers/
└── ui/
    ├── home_page.dart
    ├── log_page.dart
    ├── recap_page.dart
    ├── settings_page.dart
    ├── add_goal_page.dart
    └── widgets/
        └── mood_monster.dart
```

## Future Improvements

Some things that could be added later:

* reminders
* better stats
* exporting logs
* cloud sync
* more customization

## Demo

Demo video: [https://drive.google.com/file/d/19b6cB9TmesHIDhWj975bZC8J8JPPztr5/view?usp=sharing]
## Authors

Made by **Raghad Asslany** and **Ousama Jamal** for a Flutter mobile app project.

GitHub: [https://github.com/raghadasslany](https://github.com/raghadasslany)

```
```
