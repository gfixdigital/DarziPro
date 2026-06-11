import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Darzi Pro — Typography System
/// Font: Inter (Google Fonts)
/// Based on Craftsman Utility design tokens

class AppTextStyles {
  AppTextStyles._();

  // ─── Headlines ────────────────────────────────────────────
  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.02 * 32,
    color: kTextPrimary,
  );

  static TextStyle headlineLgMobile = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.02 * 28,
    color: kTextPrimary,
  );

  static TextStyle headlineMd = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    color: kTextPrimary,
  );

  static TextStyle headlineSm = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: kTextPrimary,
  );

  // ─── Body ─────────────────────────────────────────────────
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
    color: kTextPrimary,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: kTextPrimary,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: kTextSecondary,
  );

  // ─── Labels ───────────────────────────────────────────────
  static TextStyle labelLg = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01 * 14,
    color: kTextPrimary,
  );

  static TextStyle labelSm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.04 * 12,
    color: kTextSecondary,
  );

  // ─── Specialty ────────────────────────────────────────────
  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: Colors.white,
  );

  static TextStyle currencyLg = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    color: kTextPrimary,
  );

  static TextStyle currencyMd = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    color: kTextPrimary,
  );
}
