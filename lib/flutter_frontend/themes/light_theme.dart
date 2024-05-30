import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
  ),
    colorScheme: ColorScheme.light(
      background: Color(0xFFF1F3F3),
      primary: Colors.black,
      secondary: Color(0xFF04A654),
    )
);