import 'package:flutter/material.dart';

const Color accentColor = Color.fromARGB(255, 132, 0, 255);

final theme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.white,
    indicatorColor: Colors.white,
    colorScheme: const ColorScheme.dark().copyWith(
        background: Colors.black,
        primary: Colors.white,
        tertiary: Colors.grey,
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
