import 'package:flutter/material.dart';

ThemeData basicTheme() {
  TextTheme _basicTextTheme(TextTheme base) {
    return base.copyWith(
      headline1: base.bodyText1?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          fontFamily: 'LeagueSpartan'),
      subtitle1: base.subtitle1?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: 'LeagueSpartan'),
      subtitle2: base.subtitle1?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'LeagueSpartan'),
      bodyText1: base.bodyText1?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      bodyText2:
          base.bodyText1?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
      caption: base.caption?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      button: base.subtitle1?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'LeagueSpartan'),
    );
  }

  final base = ThemeData.light();
  return base.copyWith(
      textTheme: _basicTextTheme(base.textTheme),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF4f4f4f),
      ),
      primaryColor: const Color(0xFFCB5B3F),
      primaryColorDark: const Color(0xFF4f4f4f),
      highlightColor: Color.fromARGB(255, 221, 158, 143),
      primaryColorLight: const Color(0xFFDFC344),
      scaffoldBackgroundColor: const Color(0xFfE4E0CE),
      errorColor: const Color.fromARGB(255, 182, 31, 31),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Color(0xFfE4E0CE)),
      ));
}
