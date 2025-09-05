# 📝 Task Management App

A **Flutter-based Task Management App** designed to help users **organize, track, and manage tasks efficiently**.  
This project demonstrates **state management with Provider, theming (light & dark mode), reusable widgets, and clean folder structure** for scalability.

---

## 🚀 Features
- ✅ User Authentication (Login UI)
- ✅ Task CRUD Operations (Add, Edit, Delete, View)  
- ✅ Light & Dark Theme Support  
- ✅ Reusable Widgets (custom app bar, task tile, loading indicator, empty state)  
- ✅ Splash Screen with smooth transition  
- ✅ Form Validation & Utilities (async, date-time, dialogs)  
- ✅ Clean Code Structure for maintainability  

---

## 📂 Folder Structure
''
lib/
├── constants/
│   ├── app_colors.dart      // Application color constants
│   ├── app_constants.dart   // General application constants
│   ├── app_strings.dart     // All text strings used in the app
│   └── app_styles.dart      // Text and UI styling definitions
│
├── models/
│   └── task_model.dart      // Data model for tasks
│
├── providers/
│   ├── task_provider.dart   // State management for tasks
│   └── theme_provider.dart  // Theme management (light/dark mode)
│
├── screens/
│   ├── splash_screen.dart   // Initial loading screen
│   ├── login_screen.dart    // User authentication screen
│   ├── home_screen.dart     // Main task listing screen
│   ├── add_task_screen.dart // Screen for creating new tasks
│   ├── edit_task_screen.dart// Screen for modifying existing tasks
│   └── task_detail_screen.dart // Detailed view of a single task
│
├── services/                // External service integrations
│
├── themes/
│   └── light_dart_theme.dart // Application theme definitions
│
├── utils/
│   ├── async_utils.dart     // Utilities for async operations
│   ├── date_time_utils.dart // Date and time formatting helpers
│   ├── dialog_utils.dart    // Common dialog implementations
│   ├── helpers.dart         // Miscellaneous helper functions
│   └── validators.dart      // Input validation utilities
│
├── widgets/
│   ├── custom_app_bar.dart  // Custom app bar implementation
│   ├── empty_state.dart     // Widget for empty states
│   ├── loading_indicator.dart // Custom loading indicators
│   └── task_tile.dart       // Task list item widget
│
└── main.dart                // Application entry point
''
---

## 🛠️ Tech Stack
- **Flutter** (UI framework)  
- **Dart** (Programming language)  
- **Provider** (State management)  
- **SharedPreferences** (Local storage for session/theme persistence)  

---

## 🎨 UI/UX
- Gradient backgrounds with **modern theme colors**  
- **Animations & transitions** for smooth user experience  
- Dark mode support with contrast-friendly colors  
---

## ▶️ Getting Started
### Prerequisites
- Install [Flutter](https://docs.flutter.dev/get-started/install)  
- Install [Android Studio / VS Code] with Flutter & Dart plugins  

### Run Locally
```bash
# Clone repository
git clone https://github.com/your-username/task_management.git

# Navigate to project
cd task_management

# Install dependencies
flutter pub get

# Run the app
flutter run
