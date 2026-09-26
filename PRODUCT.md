# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Stack

Flutter (user-confirmed via PRD; Health Connect, AccessibilityService, local-first storage Isar/SharedPreferences, RevenueCat IAP).

## Users

Primary: global Gen Z/millennial 18–34, phone-addicted, under-motivated to move — gamer mindset, fluent in XP/quest/reward systems (user-confirmed). They open the app in two emotionally opposite moments: (1) procrastinating/scrolling late at night when locked apps push back, and (2) starting their day deciding to earn. Success for them: complete a small health action and immediately see coins + screen time earned.

## Product Purpose

Health Leveling makes users pay for screen time with health: complete verified healthy habits/challenges → earn coins → spend coins to unlock chosen apps (TikTok, IG, YouTube, games). No coins = apps stay locked. Success = daily habit completion + unlock sessions felt as fair trades, retention via streak multiplier.

## Positioning

The mechanism a neighboring app could not copy: real app blocking paired with automatic anti-cheat verification via Health Connect (steps/workouts/sleep are sensed, not self-reported), plus structured multi-day challenges with bronze/silver/gold daily tiers. Unrot (iOS) is the concept predecessor: timer + photo self-report only.

## Operating Context

- Android phones, minSdk 26; Health Connect permission flows; AccessibilityService must be user-enabled in system settings (onboarding walks through it).
- Core loop surfaces: Home (today's challenge day + coin balance + streak), Earn (habit/session), Unlock (shop + active session timer), Progress (calendar + history).
- The moment of truth is the lock screen overlay: user taps TikTok without coins → overlay offers the trade.

## Capabilities and Constraints

- v1 (decided): AccessibilityService block engine; Health Connect + timer/photo verification; 4 challenges (Fitness Starter free, Dopamine Detox, 10K Steps, Sleep Reset); granular coin economy (2000 steps = 10 coins, push-ups ×5 = 2, etc.); streak shields (2/challenge) + coin multiplier ×1.2–2.5; freemium paywall (first challenge free); global English; local-only storage (sync-ready architecture for v2); onboarding 8–10 screens; mascot "Ember" (orange spark, non-brain).
- v2 candidates: chat-with-buddy onboarding pattern, rank/tier XP system, cloud sync, more challenges, remote-config economy tuning.
- Hard constraint: app blocking must degrade gracefully if AccessibilityService is revoked (coins still work, blocking pauses with clear state).

## Brand Commitments

- Name: Health Leveling (fixed).
- Mascot: Ember — an energetic orange spark/ember character, expressive, flat illustration style (decided; visual design TBD in design phase).
- Palette direction (user-approved): light default + full dark mode; primary energetic orange #FF6B35; support teal #14B8A6; ink near-black. Adaptive scheme, not night-only.
- Voice: to be designed from scratch this phase; example lines required before final (user-confirmed no existing reference).
- Reference concept: Unrot (iOS) — screen structure and onboarding rhythm borrowed; its green/pink identity explicitly NOT copied.

## Evidence on Hand

- docs/PRD.md — full PRD v1.0 (grill-confirmed decisions, coin tables, challenge catalog).
- research/appllama-unrot.md — Unrot teardown: concept + design-system metadata from 36 screens (Appllama MCP).
- No logo, no mascot art, no real user data, no testimonials — none may be fabricated.

## Product Principles

- The trade must feel fair and instant: health action → coins → unlock, feedback in seconds.
- Small starts win: thresholds low enough that starting is easy (user's explicit wish).
- Missing a day must not kill motivation: shields and multipliers soften failure.
- Verification is the trust engine: sensed data > self-report where possible.
- Health data never leaves the device in v1 (privacy as a feature).

## Accessibility & Inclusion

Material 3 baseline: 48dp touch targets, dynamic font scale support, dark theme first-class, TalkBack labels on progress/coin indicators.
