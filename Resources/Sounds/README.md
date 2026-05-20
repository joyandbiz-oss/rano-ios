# Rano — Alarm Sound Assets

## Required files for Sound Lab playground

Drop 4 `.caf` files into this folder with these exact names:

- `rhythm_rise.caf` (default — percussion + melody, 90-110 BPM)
- `warm_pulse.caf` (soft melodic midrange pulse)
- `bright_bell.caf` (clearer high transients, not painful)
- `urgent_classic.caf` (harsh fallback for heavy sleepers)

## Format constraints (per Codex + Apple docs)

- Container: `.caf` (Core Audio Format) — Apple's recommended for alarm/notification sounds
- Codec: PCM 16-bit or IMA4
- Sample rate: 44.1 kHz
- Channels: mono (1)
- Duration: **29 seconds max** (longer → silently falls back to system default)
- Internal volume envelope: ramp -12dB → 0dB over 20s, then sustain

> iOS 26.0 has a confirmed bug where sounds in `Library/Sounds` fall back silently
> ([Apple Forums #798140](https://developer.apple.com/forums/thread/798140)). We
> ship them in the app bundle to avoid that path.

## Generation workflow (V1, ~$10)

1. **Suno AI** (https://suno.com, $10/mo) — generate 4 melodic loops.
   Example prompt: `gentle escalating wake-up melody, soft piano + warm pulse, 90 BPM, 29 seconds, builds from soft to assertive`
2. Download as MP3.
3. **Audacity** (free, https://www.audacityteam.org/):
   - Import MP3
   - Trim to 29 seconds
   - Convert mono, 44.1 kHz
   - Apply Envelope tool: -12dB at 0s, 0dB at 20s, hold to 29s
   - Export as `.caf` (PCM 16-bit)
4. Drop into this folder with the correct file name.
5. Rebuild app — playground sees them automatically.

## Test protocol (Sound Lab)

Per file, validate in 4 modes:

| Mode | Expected | Notes |
|---|---|---|
| Silent switch ON | Alarm plays full volume | AlarmKit overrides per WWDC 2025 Session 230 |
| Focus → Sleep | Alarm pierces, Lock Screen takeover | Apple commitment |
| DND on Lock Screen | Alarm pierces | Same path as Sleep |
| AirPods connected | Alarm SHOULD route to speaker (but iOS 26 routes to BT — known limitation) | Must warn user in onboarding |
| Headphones with Reduce Loud Sounds | Volume capped | System policy, no override |
