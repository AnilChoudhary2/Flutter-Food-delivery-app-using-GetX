import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData dark({Color color = const Color(0xFFe86819)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xFFe86819),
  disabledColor: const Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: Colors.black,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)), colorScheme: ColorScheme.dark(primary: color, secondary: color).copyWith(background: const Color(0xFF343636)).copyWith(error: const Color(0xFFdd3135)),
);
