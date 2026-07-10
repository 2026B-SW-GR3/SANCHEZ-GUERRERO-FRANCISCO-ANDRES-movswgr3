import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Escala tipográfica del clon Airbnb.
///
/// Sustituye Airbnb Cereal (propietaria) por **Inter Variable** (open-source).
/// Pesos modestos: el peso visual viene de la foto, no del tipo.
///
/// Referencia: análisis de fase 1 → sección 4. Tipografía.
class AppTextStyles {
  AppTextStyles._();

  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        const TextTheme().apply(bodyColor: AppColors.ink),
      );

  // ─── Display & headings ─────────────────
  static TextStyle ratingDisplay = GoogleFonts.inter(
    fontSize: 64, fontWeight: FontWeight.w700,
    height: 1.1, letterSpacing: -1, color: AppColors.ink,
  );

  static TextStyle displayXL = GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700,
    height: 1.43, color: AppColors.ink,
  );

  static TextStyle displayL = GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w500,
    height: 1.4, color: AppColors.ink,
  );

  static TextStyle titleM = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600,
    height: 1.4, color: AppColors.ink,
  );

  // ─── Body ───────────────────────────────
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    height: 1.43, color: AppColors.ink,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.5, color: AppColors.foggy,
  );

  // ─── Captions & tags ────────────────────
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500,
    height: 1.4, color: AppColors.ink,
  );

  static TextStyle uppercaseTag = GoogleFonts.inter(
    fontSize: 8, fontWeight: FontWeight.w700,
    height: 1.0, letterSpacing: 0.32,
    color: AppColors.canvas,
  );

  // ─── Buttons ────────────────────────────
  static TextStyle buttonPrimary = GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w500,
    color: AppColors.canvas,
  );

  // Aliases útiles
  static TextStyle get h1 => displayXL;
  static TextStyle get h2 => displayL;
  static TextStyle get h3 => titleM;
}
