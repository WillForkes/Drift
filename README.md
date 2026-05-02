# Drift

A focus app built around physical NFC tags. Tap a tag to start a session — Drift blocks distracting apps and shows a live timer on the lock screen. Tap again to stop.

## Features

- **NFC-triggered sessions** — tap a physical tag to start and stop focus
- **Multiple tags** — register several tags, each with its own name and preset
- **Focus presets** — configure which apps get blocked per session, with a custom emoji
- **App blocking** — uses Screen Time API to enforce blocking during sessions
- **Live Activity** — lock screen timer showing elapsed session time with Dynamic Island support
- **Analytics** — streak tracking, daily focus time, and a weekly graph
- **Shield screen** — custom blocked-app UI matching the Drift design
- **Fully local** — no backend, everything stored on-device via App Groups

## How it works

1. Write a URL with a unique ID to an NFC tag (`drift://focus?id=0001` or the production Universal Link)
2. Open Drift and tap the tag — the app walks you through registration and Screen Time authorization
3. Give the tag a name and assign it a focus preset
4. From then on, tapping the tag toggles focus sessions on and off

## Project structure

```
Drift/
├── App/
│   └── DriftApp.swift
├── Core/
│   ├── Managers/
│   │   ├── FocusSessionManager.swift      # Session state, Screen Time & Live Activity
│   │   ├── DriftTagManager.swift          # NFC tag registration
│   │   ├── PresetManager.swift            # Focus preset management
│   │   ├── AnalyticsManager.swift         # Session tracking
│   │   ├── NFCReaderManager.swift         # NFC scanning
│   │   └── ParentalControlsManager.swift  # Parental controls passcode
│   ├── Models/
│   │   └── FocusPreset.swift
│   ├── Services/
│   │   ├── NFCFocusCoordinator.swift      # Coordinates NFC detection with session state
│   │   └── HapticManager.swift
│   └── SharedDefaults.swift               # App Groups UserDefaults helper
├── Screens/
│   ├── Home/
│   ├── ActiveSession/
│   ├── Analytics/
│   ├── Settings/
│   ├── ParentalControls/
│   └── Onboarding/
├── Components/
│   ├── DriftButton.swift
│   ├── PillBadge.swift
│   ├── BottomPresetSlider.swift
│   ├── StatCard.swift
│   ├── WeeklyFocusGraph.swift
│   └── DriftSelector.swift
└── DesignSystem/
    ├── DesignTokens.swift
    ├── Typography.swift
    └── LayoutExtensions.swift

DriftWidget/                               # Live Activity widget extension
DriftShieldConfiguration/                 # Custom blocked-app screen extension
```

## Setup

1. Open `Drift.xcodeproj` in Xcode
2. Set the deployment target to iOS 17.0+
3. Configure signing with your team
4. Make sure the required entitlements are in place (see below)

### NFC tag format

Both URL schemes are supported:

```
drift://focus?id=0001          # custom scheme (dev)
https://links.get-drift.app/focus?id=0001  # Universal Link (production)
```

Use any NFC writing app (NFC Tools works well) with a writable NTAG213/215/216 tag.

### Universal Links

Host an `apple-app-site-association` file at `https://links.get-drift.app/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appID": "TEAMID.com.yourcompany.Drift",
      "paths": ["/focus"]
    }]
  }
}
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Physical device for NFC and Screen Time features (Simulator won't work)
- iPhone XS or later for NFC

### Entitlements

- `com.apple.developer.family-controls` — app blocking via Screen Time
- `com.apple.developer.nfc.readersession.formats` — NFC reading
- `com.apple.developer.associated-domains` (`applinks:links.get-drift.app`) — Universal Links

## Design system

Colors: warm beige `#F7F0E9`, soft peach `#E2B899`, burnt orange `#C86A1C`  
Font: Futura PT Book (bundled)  
Sizes: 48pt / 28pt / 22pt / 20pt / 18pt

## Disclaimer

This project was developed with the assistance of Claude Code (Anthropic, 2025). Claude Code was used as a collaborative development tool to aid in the design, implementation, and refinement of this codebase.

Anthropic (2025) *Claude Code* [AI coding assistant]. Available at: https://claude.ai/code (Accessed: 20 October 2025).

## Production checklist

- [x] Universal Links
- [x] Memory leaks resolved
- [x] Live Activity
- [x] Analytics
- [x] Shield configuration
- [ ] Family Controls Distribution entitlement approval
- [ ] Privacy Policy
- [ ] App Store assets
