import 'package:flutter/material.dart';

/// Tokens oficiales de Airbnb (live UI actual, no legacy).
///
/// Marca: Rausch (#FF5A5F) · Live UI: #FF385C
///
/// Referencia: análisis de fase 1 → sección 2. Psicología del color.
class AppColors {
  AppColors._();

  // ───────────────────────────────────────
  // PRIMARY · Rausch
  // ───────────────────────────────────────
  static const Color rausch       = Color(0xFFFF385C); // live UI ★
  static const Color rauschLegacy = Color(0xFFFF5A5F); // brand / logo
  static const Color rauschActive = Color(0xFFE00B41); // pressed
  static const Color rauschDisable= Color(0xFFFFD1DA); // disabled

  // ───────────────────────────────────────
  // SECONDARY · Babu (teal)
  // ───────────────────────────────────────
  static const Color babu = Color(0xFF00A699);

  // ───────────────────────────────────────
  // ACCENT · Arches (orange)
  // ───────────────────────────────────────
  static const Color arches = Color(0xFFFC642D);

  // ───────────────────────────────────────
  // NEUTRALS · texto y superficies
  // ───────────────────────────────────────
  static const Color ink        = Color(0xFF222222); // primary text
  static const Color body       = Color(0xFF3F3F3F); // body text
  static const Color hof        = Color(0xFF484848); // dark grey
  static const Color foggy      = Color(0xFF767676); // muted text
  static const Color canvas     = Color(0xFFFFFFFF); // fondo principal
  static const Color softSurface= Color(0xFFF7F7F7); // cards/inputs
  static const Color hairline   = Color(0xFFEAEAEA); // bordes

  // ───────────────────────────────────────
  // SUB-BRANDS (uso restringido)
  // ───────────────────────────────────────
  static const Color luxe = Color(0xFF460479);
  static const Color plus = Color(0xFF92174D);

  // ───────────────────────────────────────
  // SEMANTIC (feedback de sistema)
  // ───────────────────────────────────────
  static const Color success = Color(0xFF008A05);
  static const Color warning = Color(0xFFFFB400);
  static const Color error   = Color(0xFFC13515);
}
