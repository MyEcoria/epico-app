import 'package:flutter/material.dart';

const Color kAccentColor = Color(0xFFEF5466);

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    primary: kAccentColor,
    secondary: kAccentColor,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: kAccentColor,
    unselectedItemColor: Colors.white70,
  ),
);
