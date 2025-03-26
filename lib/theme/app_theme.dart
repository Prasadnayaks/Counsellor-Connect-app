import 'package:flutter/material.dart';

class AppTheme {
  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.normal,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.normal,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.purpleAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

