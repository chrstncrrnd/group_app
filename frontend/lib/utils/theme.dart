import 'package:flutter/material.dart';

const Color accentColor = Color.fromARGB(255, 126, 126, 126);

final theme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    cardTheme: const CardTheme(surfaceTintColor: Colors.white),
    primaryColor: Colors.white,
    indicatorColor: Colors.white,
    popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: Colors.white.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    colorScheme: const ColorScheme.dark().copyWith(
        background: Colors.black,
        primary: Colors.white,
        tertiary: Colors.grey,
        error: const Color.fromARGB(255, 148, 41, 41),
        secondary: accentColor),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey.shade700,
    ),
    // i profoundly dislike splashes
    splashColor: Colors.transparent,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
    buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
    useMaterial3: true);
