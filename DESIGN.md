# Health Leveling — DESIGN.md

Design record for the Home screen (v1), generated at the close of the impeccable
build phase (comp-first path, direction **Ember Meter**).

## Direction

- **Ember Meter** — warm instrument-panel energy: the day's momentum reads like a
  gauge, not a dashboard. Mascot **Ember** (orange droplet) lives inside the ring.
- Comp: `.impeccable/mocks/home-a.png` (Komp A, locked). Measured palette:
  ivory `#f8f8ef` (81% of comp pixels), ember orange `#f0671e` (15%), teal
  `#12b49f`, near-black ink `#0a0d15`.
- Typography: **M PLUS 1p** — measured from the comp challenge-card cap height
  (24.5px ⇒ 400 weight @ 35px in 576-space). 400/700/800 TTFs vendored in
  `assets/fonts/`.

## Home contract (576×1024 comp space)

| Region | Grid | Content |
|---|---|---|
| status-bar | A0:J0 | time 8:41 + signal/wifi/battery (authored) |
| title-bar | A1:J1 | back chevron · "Health Leveling" · overflow |
| coin-chip | A2:C2 | teal pill "1,240 coins", overlaps ring top-left |
| coin-numeral | H1:J3 | rotated −42° "1,240", ink |
| gauge-arc | B2:H6 | two-stop ember ring, 8 tick marks, top seam |
| gauge-plate | C3:G5 | Ember mascot raster (`assets/plates/gauge-plate.png`, gate-passed 0.6058) |
| challenge-card | A6:J8 | "Day 4 · Fitness Starter" + 35% teal track |
| cta-start | B8:I8 | ember "Start session" pill |
| bottom-nav | A9:J9 | star (teal) · + fab · padlock (authored SVG) |

Below the fold (sections phase): Your challenges list (Fitness Starter active;
Dopamine Detox, Langkah Harian, Sleep Reset locked), Today's coins ledger
(2000 steps +10 · push-up ×5 +2 · squat ×5 +2 · workout 15m +15 · streak ×1.5),
Streak card (7 dots, day 4, ×2.0 target).

## Coin economy (PRD §4, guarded by test/design_system_test.dart)

2,000 steps = 10 · push-up ×5 = 2 · squat ×5 = 2 · workout 15 min = 15 ·
unlock 20 coins = 10 min · streak ×1.2–×2.5 (shields protect days, not multiplier).

## Gate record

- comps ✅ · spec ✅ · plates ✅ (check-plate 0.6058 ok)
- hero 61% → user-approved downgrade (garbled AI glyphs unreproducible) — FORCED
- sections ✅ · motion ✅ (FORCED records, same reason)
- responsive: desktop best **67%** (direct 576×1024 record), fluid-% mobile layout
  at 390px — FORCED, same user quote
- finish review (inline): disposition **fix** — 4 material fixes applied & verified:
  1. emoji nav icons → authored SVG (star/plus/padlock/shield/activity)
  2. challenge-card clipping at 576 width
  3. safe margins for rotated numeral & chip on mobile
  4. chip z-order above ring SVG

Known residual: remaining delta to 72% concentrates in text-glyph interiors of
status-bar/title-bar/coin-numeral, where the AI comp renders garbled lettering
(no real text can match). Accepted by user (option A) and recorded as FORCED.

## Flutter mapping

`lib/design/tokens.dart` (`Ds`): colors above + economy constants.
`lib/features/home/home_screen.dart`: gauge ring `CustomPaint`, chip, numeral,
plate `Image.asset`, challenge card, progress bar, CTA, bottom nav.
Tests: `test/design_system_test.dart` (palette + economy), `test/home_screen_test.dart`
(hero renders). `flutter analyze` clean · `flutter test` 3/3.
