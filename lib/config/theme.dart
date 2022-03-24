import 'package:flutter/material.dart';

ThemeData basicTheme() {
  TextTheme _basicTextTheme(TextTheme base) {
    return base.copyWith(
      headline1: base.headline1?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      headline2: base.headline2?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      subtitle1: base.subtitle1?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyText1: base.bodyText1?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  final base = ThemeData.light();
  return base.copyWith(
      textTheme: _basicTextTheme(base.textTheme),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFFDE9B9B),
      ),
      primaryColor: const Color(0xFF6093AF),
      primaryColorDark: const Color(0xFF4f4f4f),
      primaryColorLight: const Color(0xFFE3DFCC),
      scaffoldBackgroundColor: const Color(0xFfBDBDBD),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Color(0xFfBDBDBD)),
      ));
}
