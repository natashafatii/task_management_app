import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';
import 'themes/light_dart_theme.dart'; // import your custom theme

// Declare a global variable to hold the SharedPreferences instance
late SharedPreferences sharedPreferences;

void main() async {
  // Ensure Flutter's widget binding is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences and assign it to the global variable
  sharedPreferences = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Task Management App',
        theme: AppTheme.lightTheme,       // Light mode
        darkTheme: AppTheme.darkTheme,    // Dark mode
        themeMode: ThemeMode.system,      // 👈 Follows system setting
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
