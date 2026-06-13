import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Darzi Pro — Typography System
/// Font: Inter (Google Fonts)
/// Based on Craftsman Utility design tokens

class AppTextStyles {
  AppTextStyles._();

  // ─── Headlines ────────────────────────────────────────────
  static TextStyle headlineLg = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 40 / 32,
    letterSpacing: -0.015 * 32,
    color: kTextPrimary,
  );

  static TextStyle headlineLgMobile = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 36 / 28,
    letterSpacing: -0.015 * 28,
    color: kTextPrimary,
  );

  static TextStyle headlineMd = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: kTextPrimary,
  );

  static TextStyle headlineSm = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    color: kTextPrimary,
  );

  // ─── Body ─────────────────────────────────────────────────
  static TextStyle bodyLg = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
    color: kTextPrimary,
  );

  static TextStyle bodyMd = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    color: kTextPrimary,
  );

  static TextStyle bodySm = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
    color: kTextSecondary,
  );

  // ─── Labels ───────────────────────────────────────────────
  static TextStyle labelLg = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01 * 14,
    color: kTextPrimary,
  );

  static TextStyle labelSm = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.02 * 12,
    color: kTextSecondary,
  );

  // ─── Specialty ────────────────────────────────────────────
  static TextStyle buttonText = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 24 / 15,
    color: Colors.white,
  );

  static TextStyle currencyLg = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 36 / 28,
    color: kTextPrimary,
  );

  static TextStyle currencyMd = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 28 / 20,
    color: kTextPrimary,
  );
}
