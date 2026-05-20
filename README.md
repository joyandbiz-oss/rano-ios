# Rano — ADHD-friendly Morning Routine + Step Alarm

iOS 26+ app for women with ADHD who can't get out of bed without external structure.

**Status:** V0.1 prototype — AlarmKit Sound Lab playground for validating sound + Silent/Focus/DND/AirPods behavior before V1 spec build.

## Day 0-1 mission: validate AlarmKit reliability

Per Codex/Opus dual review, **the #1 risk for V1 is not product design — it's AlarmKit reliability + custom sound assets** on iOS 26.0. Before writing any product code, we must prove:

1. Custom `.caf` sounds load and loop correctly in bundle
2. Alarm pierces Silent switch + Focus modes + DND + Lock Screen
3. Apple Watch presentation works (or document limits)
4. AirPods/Bluetooth routing behavior (warn user in onboarding)
5. `Library/Sounds` fallback bug confirmed/worked around ([Apple Forums #798140](https://developer.apple.com/forums/thread/798140))

This repo's `PlaygroundView` is a manual harness for that validation.

## Build & run

```bash
# 1. Generate Xcode project
xcodegen generate

# 2. Open in Xcode 16+ (iOS 26 SDK required)
open Rano.xcodeproj

# 3. Add sound files to Resources/Sounds/ (see Resources/Sounds/README.md)

# 4. Build & run on a physical iPhone with iOS 26
#    (Simulator won't fully test alarm behavior)
```

## Test protocol

See `Resources/Sounds/README.md` for the 4-mode validation matrix.

In the app:
1. Tap **Request alarm permission**
2. Pick a sound preset (segmented control)
3. Pick a fire delay (15s / 30s / 60s / 300s)
4. Tap **Fire in Xs**
5. Lock the phone + change system state (Silent / Focus / DND / AirPods)
6. When the alarm fires, observe sound + Lock Screen takeover + Dynamic Island
7. Tap **Got up** to dismiss
8. Check the in-app **Log** + Xcode console for `[Rano]` lines

## V1 spec (locked, NOT in this prototype)

- AlarmKit hostile alarm
- 3 step-difficulty tiers (15/25/50 steps + walking-activity gate)
- Honor-system micro-coaching (Sit up, Feet on floor)
- HealthKit sleep-debt mode (<5h → soft mode + 25-min nap)
- Live Activity Lock Screen + Dynamic Island
- Pre-bed wind-down nudge (user-set, NOT hard-coded 10pm)
- Cycle-aware luteal mode
- Weekly reflection
- V1.1 Pro: NFC tag mode (user buys $7 stickers from Amazon)

Photo verification: SKIP entirely (Codex verdict — Vision feature print can't distinguish "photo of photo" from real object).

## Stack

- Xcode 16+ iOS 26 SDK
- SwiftUI
- AlarmKit (alarm engine)
- ActivityKit (Live Activity, V1)
- CoreMotion (V1)
- HealthKit (V1)
- StoreKit 2 (V1 paywall)

No backend. All on-device.

## Pricing (V1)

Freemium + $19.99/yr + $39.99 Lifetime.

## 4.3 mitigation (vs Mocho, same dev account)

- Different bundle ID (`com.andriibyzov.rano`)
- Different category (Lifestyle, not Medical)
- Different mechanic (active intervention + alarm vs Mocho's passive tracking)
- "ADHD" NOT in app title — only in subtitle/description
- Stagger 3+ weeks after Mocho V1.0.2 / V1.1 submissions
