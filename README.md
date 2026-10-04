# ⏱️ Time Tracker

A clean and intuitive **Flutter** app for tracking time across projects and tasks. Log work sessions, manage projects, and stay on top of how you spend your time — all stored locally on your device.

## ✨ Features

- **Time Logging** — Record time entries with start/end times linked to a project and task
- **Project Management** — Create and manage projects to organise your work
- **Task Management** — Define tasks within projects for granular time tracking
- **Local Persistence** — All data saved locally using `shared_preferences` (no account required)
- **Cross-Platform** — Runs on Android, iOS, Windows, macOS, Linux, and Web

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Local Storage | shared_preferences |
| Date/Time Formatting | intl |

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.13.3`
- Dart `^3.13.3`

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/time_tracker.git
cd time_tracker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── project.dart                   # Project model
│   ├── task.dart                      # Task model
│   └── time_entry.dart                # Time entry model
├── providers/
│   └── time_entry_provider.dart       # State management & local persistence
└── screens/
    ├── home_screen.dart               # Dashboard & time entries list
    ├── add_time_entry_screen.dart     # Log a new time entry
    ├── project_management_screen.dart # Manage projects
    └── task_management_screen.dart    # Manage tasks per project
```

## 📄 License

This project is open source. Feel free to use, modify, and distribute it.
