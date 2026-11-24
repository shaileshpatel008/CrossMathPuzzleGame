import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.onGold,
        secondary: AppColors.violet,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.coral,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: GoogleFonts.inter().fontFamily,
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      splashFactory: InkSparkle.splashFactory,
      dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface2,
        contentTextStyle: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.mint : AppColors.line,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
