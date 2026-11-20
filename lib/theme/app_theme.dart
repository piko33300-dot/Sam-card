import 'package:flutter/material.dart';
import 'package:shop/theme/button_theme.dart';
import 'package:shop/theme/input_decoration_theme.dart';

import '../constants.dart';
import 'checkbox_themedata.dart';
import 'theme_data.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: blackColor),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: blackColor40),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(defaultPadding),
          backgroundColor: primaryColor,
          foregroundColor: blackColor,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
          ),
        ),
      ),
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(
        borderColor: primaryColor,
      ),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    const surfaceColor = Color(0xFF17181C);
    const cardColor = Color(0xFF202126);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: samCardGold,
      onPrimary: blackColor,
      secondary: samCardGoldLight,
      onSecondary: blackColor,
      surface: surfaceColor,
      onSurface: Colors.white,
      error: errorColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: samCardGold,
      scaffoldBackgroundColor: blackColor,
      colorScheme: colorScheme,
      canvasColor: surfaceColor,
      cardColor: cardColor,
      dividerColor: const Color(0xFF34363D),
      iconTheme: const IconThemeData(color: samCardGoldLight),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: whileColor80,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: whileColor80),
        bodySmall: TextStyle(color: whileColor40),
        labelLarge: TextStyle(
          color: blackColor,
          fontWeight: FontWeight.w700,
        ),
        labelMedium: TextStyle(color: whileColor60),
        labelSmall: TextStyle(color: whileColor40),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(defaultPadding),
          backgroundColor: samCardGold,
          foregroundColor: blackColor,
          disabledBackgroundColor: samCardGoldDark,
          disabledForegroundColor: whileColor40,
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: samCardGold,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: samCardGold,
          padding: const EdgeInsets.all(defaultPadding),
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(
            width: 1.5,
            color: samCardGold,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
          ),
        ),
      ),
      inputDecorationTheme: darkInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return samCardGold;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(blackColor),
        side: const BorderSide(color: whileColor40),
      ),
      appBarTheme: appBarDarkTheme,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(samCardGold),
        trackColor: MaterialStateProperty.all(const Color(0xFF292A2F)),
      ),
      dataTableTheme: dataTableDarkThemeData,
      dialogTheme: const DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(defaultBorderRadious),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
