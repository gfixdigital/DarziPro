import 'package:flutter/material.dart';

/// Darzi Pro — Craftsman Utility Design System Colors
/// Based on Stitch "Smart Darzi Manager" design system

// ─── Primary Palette ──────────────────────────────────────────
const kPrimary = Color(0xFF2563EB);          // GFix Digital Blue — buttons, active states
const kPrimaryDark = Color(0xFF1E3A8A);      // Dark blue — app bar, emphasis
const kPrimaryLight = Color(0xFFEFF4FF);     // Very light blue — card backgrounds
const kPrimaryContainer = Color(0xFF3B82F6); // Container blue
const kOnPrimaryContainer = Color(0xFFE0ECFF); // On container

// ─── Surface & Background ─────────────────────────────────────
const kBackground = Color(0xFFF8FAFC);       // Clean slate-tinted off-white
const kSurface = Color(0xFFFFFFFF);          // White — cards, inputs
const kSurfaceContainer = Color(0xFFF1F5F9); // Surface container (slate-100)
const kSurfaceContainerHigh = Color(0xFFE2E8F0); // Slate-200
const kSurfaceContainerLow = Color(0xFFF8FAFC);  // Slate-50

// ─── Accent ───────────────────────────────────────────────────
const kAccentGold = Color(0xFFD4AF37);       // Gold — urgent orders, premium
const kTertiary = Color(0xFF735C00);         // Tertiary — accent
const kTertiaryContainer = Color(0xFFCCA830);

// ─── Text ─────────────────────────────────────────────────────
const kTextPrimary = Color(0xFF0F172A);      // Dark slate — primary text (slate-900)
const kTextSecondary = Color(0xFF64748B);    // Slate grey — secondary text (slate-500)
const kOnSurfaceVariant = Color(0xFF475569);  // On surface variant (slate-600)

// ─── Status ───────────────────────────────────────────────────
const kError = Color(0xFFBA1A1A);            // Red — errors, overdue
const kErrorContainer = Color(0xFFFFDAD6);
const kOnError = Color(0xFFFFFFFF);

// ─── Border & Outline ─────────────────────────────────────────
const kBorder = Color(0xFFCBD5E1);           // Light border (slate-300)
const kOutline = Color(0xFF64748B);          // Outline (slate-500)

// ─── Inverse ──────────────────────────────────────────────────
const kInverseSurface = Color(0xFF1E293B);    // Slate-800
const kInverseOnSurface = Color(0xFFF8FAFC);
const kInversePrimary = Color(0xFF93C5FD);   // Blue-300

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
