import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography helpers: Sora for display / numbers, Inter for body copy.
class AppText {
  AppText._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.sora(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing ?? (size >= 28 ? -0.8 : -0.2),
    height: height,
  );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle label({Color color = AppColors.muted}) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: color);

  static TextStyle muted(double size, {FontWeight weight = FontWeight.w500}) =>
      body(size, weight: weight, color: AppColors.muted);
}
