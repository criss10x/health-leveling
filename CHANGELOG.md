# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-16

First MVP build — the full earn-your-screen-time loop works end to end.

### Added

- **App blocking engine** (PRD §6): AccessibilityService detects foreground apps;
  locked apps get a full-screen lock overlay ("App locked — earn coins") with a
  live countdown when an unlock session is active.
- **Coin economy** (§4): 7 sources (steps/workout/sleep via Health Connect,
  push-ups/squats/meditation/water manual), streak multiplier ×1.0–×2.5,
  anti-abuse caps (water 8/day, reps 100/day, HC sources verify-once-per-day).
- **Unlock packages** (§4.2): 10 min / 20 coins, 30 min / 50, 1 hour / 90.
- **Streak & shields** (§4.3, §5): daily miss resets streak, 2 shields per
  challenge auto-cover a missed day, shields never boost the multiplier.
- **Challenge catalog** (§5): Fitness Starter (21d, free), Dopamine Detox (7d),
  10K Steps (30d), Sleep Reset (14d) with bronze/silver/gold daily tiers and
  completion bonuses; detail screen with a day-by-day calendar
  (done / shielded / missed / in-progress / future states).
- **Onboarding** (§7): 8 screens — hero, problem, how-it-works, first-challenge
  pick, daily criteria, notification permission, accessibility disclosure,
  ready.
- **Home** (Ember Meter, approved comp A): gauge ring + Ember mascot, coin chip
  & numeral, challenge card, Start session CTA; nav to Challenges & Unlock.
- **Persistence** (§9): append-only event ledger (JSON snapshot, replay-safe —
  corrupt events skipped individually), sync-ready for cloud in v2.
- Health Connect integration skeleton (steps 2000+, workout 15m+, sleep 7h+
  thresholds) with minSdk 26.
- CI: GitHub Actions — zero-warning analyze, full test suite, arm64 release APK
  artifact on every push to main.

### Notes

- Paywall/IAP intentionally deferred (MVP is free-only).
- Blocking behavior on aggressive OEMs (Xiaomi/Samsung killing accessibility
  after reboot) needs real-device testing before wide distribution.

[1.0.0]: https://github.com/criss10x/health-leveling/releases/tag/v1.0.0
