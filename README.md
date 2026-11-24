# CrossMathPuzzle – Math Puzzle Game

Crossword-style maths puzzles for Android & iOS, built with **Flutter + GetX**.

- **Package / application ID:** `sp.math.puzzle.games.crossmathpuzzle.play`
- **Design mockup:** the approved canvas (28 screens + 3 spec boards) — every screen below maps to an artboard number.

## Quick start

```bash
flutter pub get
flutter test
flutter run
```

Debug builds always use **Google's test ad units**, so you can tap ads safely.

## Folder structure (GetX pattern)

```
lib/
├── main.dart                     # service bootstrap + GetMaterialApp
├── app/
│   ├── bindings/                 # InitialBinding (app-wide controllers)
│   ├── constants/                # app, AdMob, IAP product IDs, storage keys
│   ├── routes/                   # app_routes.dart (names) + app_pages.dart (GetPage table)
│   ├── theme/                    # colours, typography, ThemeData, 8 board themes
│   └── utils/                    # formatters (time, dates, countdowns)
├── data/
│   ├── engine/                   # puzzle generator, uniqueness solver, evaluator, seeded RNG
│   ├── models/                   # Puzzle, Difficulty tiers, GameArgs, LevelResult, achievements
│   └── services/                 # GetxServices: storage, settings, progress, ads, purchases,
│                                 # audio, haptics, notifications, connectivity
├── modules/<feature>/            # <feature>_binding.dart / _controller.dart / _view.dart (+ widgets/)
└── widgets/                      # shared UI kit: 3D buttons, cards, dialogs, ad widgets, confetti
```

## Screens & features (artboard → code)

| # | Screen | Module |
|---|--------|--------|
| 01 | Splash (animated, loads consent + ads) | `modules/splash` |
| 02 | Ads consent — Google UMP (EEA/UK only) | `data/services/ads_service.dart` |
| 03 | How to play (3 pages; also from Pause/Settings) | `modules/onboarding` |
| 04 | Guided Level 1 with coach marks | `modules/tutorial` |
| 05 | Daily gift (7-day streak, ×2 with video, day-7 theme) | `modules/home/widgets/daily_gift_dialog.dart` |
| 06 | Home (level card, daily, quick play, offers, bottom nav, back → exit dialog) | `modules/home` |
| 07 | Level map / journey (tiers, chapters of 20, stars, replay) | `modules/level_map` |
| 08 | Quick Play difficulty sheet (Easy → Master, unlocks, best times) | `modules/home/widgets/quick_play_sheet.dart` |
| 09 | Daily challenge calendar (streak, monthly trophy, missed-day unlock) | `modules/daily` |
| 10 | Daily complete & trophy cabinet, share | `modules/daily/daily_complete_*` |
| 11 | Gameplay: tap cell → tap tile, auto-check, undo, erase, hints, timer, mistakes, equation shimmer, pinch-zoom, banner, save/resume | `modules/game` |
| 12 | Pause (stats, sound/music/vibrate/auto-check toggles, restart, home, how to play) | `game/widgets/game_dialogs.dart` |
| 13 | Out of hints (reward video 5/day, hint packs, VIP) | `game/widgets/game_dialogs.dart` |
| 14 | Out of mistakes (second chance via video, free for VIP) | `game/widgets/game_dialogs.dart` |
| 15 | Level complete (stars, stats, ×3 reward video, chapter bonus, award toasts, rate prompt) | `modules/level_complete` |
| 16 | Ad break → interstitial, with Remove-Ads offer | `modules/ad_break` |
| 17 | Store (VIP, Remove Ads, Starter Pack countdown, hint packs, free video, restore) | `modules/store` |
| 18 | VIP paywall (weekly / monthly / yearly + 3-day trial) | `modules/vip` |
| 19 | Checkout ("Connecting to Google Play…" → system billing sheet) | `modules/purchase/purchase_flow_controller.dart` |
| 20 | Purchase success | `modules/purchase/purchase_views.dart` |
| 21 | Pending / failed / restored / nothing to restore | `modules/purchase/purchase_views.dart` |
| 22 | Statistics (per difficulty, 7-day chart) | `modules/stats` |
| 23 | Awards (14 achievements, claim hints) | `modules/achievements` |
| 24 | Themes (8 themes, live preview, number size) | `modules/themes` |
| 25 | Settings (gameplay, sound, appearance, reminder time, purchases, privacy, support, reset) | `modules/settings` |
| 26 | Rate us (4–5★ → Play review, 1–3★ → feedback e-mail) | `widgets/dialogs.dart` |
| 27 | Exit dialog with native ad | `modules/home/widgets/exit_dialog.dart` |
| 28 | Offline banner / "No video right now" | `widgets/common.dart`, `widgets/dialogs.dart` |

## Levels & difficulty

Levels are generated on-device from a seed (`data/engine/generator.dart`), so every player gets the same Level N and the same daily puzzle, offline. Each puzzle is checked by a solver to have **exactly one solution**.

| Tier | Levels | Grid (max) | Operators | Numbers | Extra |
|------|--------|-----------|-----------|---------|-------|
| Tutorial | 1–5 | 5×5 | + − | ≤10 | Level 1 is the guided puzzle |
| Easy | 6–60 | 7×7 | + − | ≤30 | |
| Medium | 61–120 | 7×7 | + − × | ≤60 | |
| Hard | 121–400 | 9×9 | + − × ÷ | ≤100 | whole-number division only |
| Expert | 401–1000 | 11×11 | all, 7-cell equations | ≤200 | × ÷ before + −, 2 decoy tiles |
| Master | 1001+ | 13×13 | all, 7-cell equations | ≤999 | 4 decoys, 2-mistake limit, auto-check off |

Blank count and equation count ramp up *within* each tier. Tune everything in `data/models/difficulty.dart`; `test/engine_test.dart` verifies validity and uniqueness for every tier.

## Monetization setup (before release)

### 1. AdMob
1. Create an AdMob app for Android (and iOS) and five ad units: **Banner, Interstitial, Rewarded, App open, Native**.
2. Paste the unit IDs into the `_prod*` constants in `lib/app/constants/ad_config.dart`.
3. Replace the **test App ID** in `android/app/src/main/AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`) and `ios/Runner/Info.plist` (`GADApplicationIdentifier`).
4. In AdMob › Privacy & messaging, publish a **GDPR consent message** (the app shows it via UMP automatically where required).

Ad rules (in `AdConfig` / `AdsService`): app-open from the 2nd session (max 1 per 4 h, after ≥30 s in background); banner on Gameplay & Level map; interstitial after every 2nd solved level from level 6 (≥90 s apart) and when leaving a finished daily; rewarded videos are always optional; native ad in the exit dialog. **Remove Ads / VIP hide every non-rewarded ad.**

### 2. Google Play Console products (Monetize › Products)
| Product ID | Type | Suggested price | Grants |
|---|---|---|---|
| `remove_ads` | In-app (one-time) | $3.99 | removes non-rewarded ads |
| `starter_pack` | In-app (one-time) | $4.99 | remove ads + 30 hints (24-h offer after level 10) |
| `hints_10` / `hints_50` / `hints_150` | In-app (consumable) | $0.99 / $2.99 / $6.99 | hints |
| `vip_weekly` | Subscription | $1.99 / week | VIP |
| `vip_monthly` | Subscription | $4.99 / month | VIP |
| `vip_yearly` | Subscription + **3-day free-trial offer** | $19.99 / year | VIP |

VIP = no ads, unlimited hints, Master mode, free missed dailies, free second chances, VIP themes.

Purchases are acknowledged via `completePurchase` (required within 3 days), consumables are credited once per purchase ID, and entitlements are restored on every launch. For extra protection, add server-side receipt validation in `PurchaseService._verify`.

**Testing:** upload a build to an internal-testing track and add licence testers in Play Console — billing only works for apps installed from Play.

### 3. Other TODOs
- `lib/app/constants/app_constants.dart`: privacy policy URL, terms URL, support e-mail.
- Release signing: create `android/key.properties`:
  ```properties
  storePassword=...
  keyPassword=...
  keyAlias=upload
  storeFile=/path/to/upload-keystore.jks
  ```
- Play Console data safety: declare Ads, Advertising ID, Purchase history, App interactions.

## Notes
- **Flutter 3.47+** deprecates `package:flutter/material.dart` in favour of `material_ui`. GetX 4.x (`GetMaterialApp`) still uses `flutter/material`, so the app does too (the deprecation lint is silenced in `analysis_options.yaml`). Migrate once GetX supports `material_ui`.
- Sounds in `assets/sounds/` are synthesised placeholders (royalty-free); swap in your own anytime.
- Fonts (Sora, Inter) load via `google_fonts` and are cached after first launch. To work fully offline from first launch, bundle the TTFs under `assets/google_fonts/`.
