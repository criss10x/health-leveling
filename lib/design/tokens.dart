import 'package:flutter/material.dart';

/// Health Leveling design tokens — measured from the approved Home comp
/// (Komp A) and the spec in .impeccable/build/spec.json.
/// Palette: ivory ground, ember orange primary, teal support, ink text.
abstract final class Ds {
  // ── Color ──────────────────────────────────────────────────────────
  static const Color ivory = Color(0xFFF8F8EF);
  static const Color ember = Color(0xFFF0671E); // primary orange
  static const Color emberSoft = Color(0xFFF3DDC9); // gauge track
  static const Color teal = Color(0xFF0AB199); // progress / accents
  static const Color ink = Color(0xFF0A0D15); // near-black text
  static const Color cardBg = Colors.white;
  static const Color navBg = Color(0xFFF7F7F7);
  static const Color barTrack = Color(0xFFE7E5DA);
  static const Color chrome = Color(0xFF8A8D90); // inactive nav

  // ── Type (measured: challenge card cap-height 24.5px → M PLUS 1p) ──
  static const String fontBody = 'MPLUS1p';
  static const double fontTitle = 24;
  static const double fontNumeral = 64;
  static const double fontChip = 24;
  static const double fontCard = 35; // spec: challenge-card
  static const double fontCta = 26;
  static const double fontNav = 12;

  // ── Radius / spacing ───────────────────────────────────────────────
  static const double rCard = 16;
  static const double rPill = 30;

  // ── Coin economy (PRD §4 — single source of truth) ─────────────────
  static const int coinsPer2000Steps = 10;
  static const int coinsPushups5x = 2;
  static const int coinsSquats5x = 2;
  static const int coinsWorkout15Min = 15;
  static const int coinsPer10MinUnlock = 20;
}
