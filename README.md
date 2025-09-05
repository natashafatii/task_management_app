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
lib/
│── constants/ # App-wide constants (colors, strings, styles)
│── models/ # Data models (TaskModel)
│── providers/ # State management (TaskProvider, ThemeProvider)
│── screens/ # UI Screens (Home, Login, Add/Edit Task, Splash, Detail)
│── services/ # Services (API/DB integration placeholder)
│── themes/ # Light & Dark theme configuration
│── utils/ # Helpers & utilities (validators, date-time, dialogs, etc.)
│── widgets/ # Reusable UI components
│── main.dart # Entry point
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
