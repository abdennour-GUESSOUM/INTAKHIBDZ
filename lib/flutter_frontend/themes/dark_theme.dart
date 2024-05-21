import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
  ),
  colorScheme: const ColorScheme.dark(
    background: Colors.black,
    primary: Colors.white,
    secondary: Color(0xFF9FE870), // 0xFF1ED760
  )
);