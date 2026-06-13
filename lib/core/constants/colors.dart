import 'package:flutter/material.dart';

/// Darzi Pro — Craftsman Utility Design System Colors
/// Based on Stitch "Smart Darzi Manager" design system

// ─── Primary Palette ──────────────────────────────────────────
const kPrimary = Color(0xFF1B3B6F);          // Bespoke Deep Sapphire — elegance, structure
const kPrimaryDark = Color(0xFF0F1E36);      // Midnight Blue — headers, strong emphasis
const kPrimaryLight = Color(0xFFF0F4F8);     // Light Sapphire Wash — card backgrounds
const kPrimaryContainer = Color(0xFF214E8F); // Cobalt Accent
const kOnPrimaryContainer = Color(0xFFE6F0FA); // Cobalt tinted text

// ─── Surface & Background ─────────────────────────────────────
const kBackground = Color(0xFFFAF9F6);       // Warm Linen / Alabaster — human, cotton-like base
const kSurface = Color(0xFFFFFFFF);          // Pure White
const kSurfaceContainer = Color(0xFFF5F3ED); // Cotton Wash — soft eggshell for nesting
const kSurfaceContainerHigh = Color(0xFFEBE6DA); // Linen Shadow
const kSurfaceContainerLow = Color(0xFFFCFAF7);  // Soft eggshell

// ─── Accent ───────────────────────────────────────────────────
const kAccentGold = Color(0xFFC5A059);       // Antique Brass / Gold — craftsmanship, precision
const kTertiary = Color(0xFF8B5A2B);         // Leather Brown
const kTertiaryContainer = Color(0xFFD2B48C); // Tan Thread

// ─── Text ─────────────────────────────────────────────────────
const kTextPrimary = Color(0xFF1C222E);      // Rich Charcoal — softer than solid black
const kTextSecondary = Color(0xFF5C6479);    // Muted Slate — secondary labels
const kOnSurfaceVariant = Color(0xFF3A4254);  // Medium Slate

// ─── Status ───────────────────────────────────────────────────
const kError = Color(0xFFBA1A1A);            // Overdue crimson
const kErrorContainer = Color(0xFFFFDAD6);
const kOnError = Color(0xFFFFFFFF);

// ─── Border & Outline ─────────────────────────────────────────
const kBorder = Color(0xFFE2DDD5);           // Warm Linen Border — soft and paper-like
const kOutline = Color(0xFF8C96AB);          // Outline slate

// ─── Inverse ──────────────────────────────────────────────────
const kInverseSurface = Color(0xFF2E3545);    // Dark Slate
const kInverseOnSurface = Color(0xFFFAF9F6);
const kInversePrimary = Color(0xFF9EC5FF);

/// Returns a status-specific color
Color getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'cutting':
      return Colors.blue;
    case 'in_progress':
      return Colors.purple;
    case 'ready':
      return kPrimary;
    case 'delivered':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

/// Returns status label text
String getStatusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'Pending';
    case 'cutting':
      return 'Cutting';
    case 'in_progress':
      return 'In Progress';
    case 'ready':
      return 'Ready';
    case 'delivered':
      return 'Delivered';
    default:
      return status;
  }
}
