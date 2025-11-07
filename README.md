# Drift - Focus Ritual iOS App

A minimalist focus app that transforms phone blocking into a positive, intentional experience. Tap a physical NFC tag to enter focus mode—blocking distracting apps with elegant design.

## Core Features

- **NFC-Triggered Sessions**: Tap an NFC tag to start/stop focus sessions instantly
- **Multi-Tag Support**: Register multiple tags with unique names and preset assignments
- **Focus Presets**: Create custom presets with emoji icons and app selections
- **App Blocking**: Blocks selected apps using Screen Time API during sessions
- **Session Analytics**: Track focus time, streaks, and session history
- **Persistent Sessions**: Sessions survive app termination and device restarts
- **Haptic Feedback**: Tactile responses during sync and success states
- **Fully Local**: No backend, all data stored securely on device

## Recent Updates

### January 2025
- ✅ **Memory Leak Fixes**: Resolved critical memory leaks causing crashes after 4-5 minutes
  - Fixed NFCReaderManager completion handler cycles
  - Added task cancellation tracking for async operations
  - Implemented DispatchWorkItem cancellation for delayed actions
  - Memory savings: 50-200 KB per session
- ✅ **Preset Emojis**: Each preset now has a customizable emoji icon
- ✅ **New Button Style**: Added `.pillTertiary` style for subtle tertiary actions
- ✅ **Haptic System**: Integrated haptic feedback during onboarding and success states
- ✅ **Lock Screen**: Active session screen displays lock icon with preset information

## Project Structure

```
Drift/
├── App/
│   └── DriftApp.swift                    # Main app with URL handling
├── Core/
│   ├── Managers/
│   │   ├── FocusSessionManager.swift     # Session state & Screen Time
│   │   ├── DriftTagManager.swift         # NFC tag registration
│   │   ├── PresetManager.swift           # Focus preset management
│   │   ├── AnalyticsManager.swift        # Session tracking
│   │   ├── NFCReaderManager.swift        # NFC scanning
│   │   └── HapticManager.swift           # Haptic feedback
│   ├── Models/
│   │   └── FocusPreset.swift             # Preset data model
│   └── Services/
│       └── NFCFocusCoordinator.swift     # Session coordination
├── Screens/
│   ├── Home/
│   │   └── HomePage.swift                # Main NFC scan page
│   ├── ActiveSession/
│   │   └── ActiveSessionScreen.swift    # Lock screen during sessions
│   ├── Analytics/
│   │   └── AnalyticsPage.swift          # Stats and history
│   ├── Settings/
│   │   ├── SettingsPage.swift           # Settings and drift management
│   │   └── PresetEditSheet.swift        # Preset configuration
│   └── Onboarding/
│       ├── OnboardingFlow.swift         # Initial setup flow
│       ├── SyncingPage.swift            # Tag registration with animations
│       └── TapToStartPage.swift         # NFC scanning prompt
├── Components/
│   ├── DriftButton.swift                # Reusable button with multiple styles
│   ├── PillBadge.swift                  # Status indicator badge
│   ├── BottomPresetSlider.swift         # Horizontal preset carousel
│   └── StatCard.swift                   # Analytics card
└── DesignSystem/
    ├── DesignTokens.swift               # Colors, spacing, typography
    └── Typography.swift                 # Text style modifiers
```

## Technical Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Required Frameworks**: SwiftUI, FamilyControls, ManagedSettings, CoreNFC

### Entitlements Required

- `com.apple.developer.family-controls` - For app blocking
- `com.apple.developer.associated-domains` - For Universal Links
  - Domain: `applinks:links.get-drift.app`
- `com.apple.developer.nfc.readersession.formats` - For NFC reading

## Setup Instructions

### 1. Xcode Configuration

1. Open `Drift.xcodeproj`
2. Set deployment target to iOS 17.0+
3. Configure signing with your team
4. Verify entitlements are included

### 2. NFC Tag Configuration

The app supports both Universal Links and custom URL schemes:

**Custom URL Scheme** (Recommended for development):
```
drift://focus?id=0001
```

**Universal Link** (Production):
```
https://links.get-drift.app/focus?id=0001
```

To program an NFC tag:
1. Get a writable NFC tag (NTAG213/215/216)
2. Use an NFC writing app (NFC Tools)
3. Write the URL with a unique ID for each tag

### 3. Universal Link Setup (Production)

Host an `apple-app-site-association` file at:
```
https://links.get-drift.app/.well-known/apple-app-site-association
```

Content:
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

## Design System

### Colors
- Background: `#F7F0E9` (warm beige)
- Accent: `#E2B899` (soft peach)
- Primary: `#C86A1C` (burnt orange)
- Text: Black with opacity variations (100%, 80%, 50%)

### Typography
- Font: **Futura PT Book** (custom font included)
- Sizes: headingXL (48pt), heading1 (28pt), heading2 (22pt), body (20pt), bodySmall (18pt)

### Button Styles
- `.primary` - Orange background, white text
- `.secondary` - White background, black text, subtle border
- `.pill` - Black background, compact size
- `.pillSecondary` - White background, compact size
- `.pillTertiary` - Transparent background, extra subtle gray border (new)

### Components
All components use consistent design tokens for spacing, shadows, and colors:
- `DriftButton` - Multi-style button component
- `PillBadge` - Status indicator with icon and text
- `StatCard` - Analytics card with icon, title, and content
- `BottomPresetSlider` - Horizontal scrolling preset selector

### Usage Example
```swift
Text("Focus Session").heading1()
DriftButton(title: "Continue", style: .primary) { }
VStack(spacing: DesignTokens.Spacing.xLarge) { }
  .padding(.large)
```

## Architecture

### Session Flow

1. **First Launch**: User completes onboarding, grants Screen Time permission
2. **Tag Registration**: Tap NFC tag → Sync screen with animated badges → Name your drift
3. **Start Session**: Tap registered tag → Apps are blocked → Lock screen shows
4. **Active Session**: Blocked apps show custom shield message
5. **End Session**: Tap tag again → Apps unblocked → Return to home

### State Management

- **Singletons**: All managers use `@MainActor` singleton pattern
- **Published Properties**: SwiftUI views observe manager state changes
- **Persistence**: UserDefaults for most data, Keychain for sensitive data
- **Session State**: Survives app termination and restarts

### Memory Management

All async operations use proper cancellation tracking:
- Tasks are stored in `@State` variables and cancelled on view dismissal
- `DispatchWorkItem` used for delayed actions with cancellation support
- Prevents memory accumulation during extended sessions

## Testing

### On Physical Device
1. Tap the centered image on HomePage to trigger manual NFC scan
2. Program NFC tags with custom URL scheme: `drift://focus?id=XXXX`
3. Tap phone on tag to toggle sessions

### Requirements
- Screen Time features require physical device (cannot test in Simulator)
- NFC requires iPhone XS or later
- Universal Links only work in TestFlight/App Store builds

## Production Checklist

- [x] Universal Links configured
- [x] NFC tags programmed
- [x] Memory leaks resolved
- [x] Haptic feedback implemented
- [x] Design system complete
- [x] Onboarding flow
- [ ] Family Controls Distribution entitlement approval
- [ ] Privacy Policy (required for Screen Time API)
- [ ] App Store assets

## Important Notes

- **Testing**: Screen Time features require a physical iOS device
- **Authorization**: Users must grant Screen Time permission for blocking
- **NFC**: Background NFC reading requires iPhone XS or newer
- **Memory**: App maintains stable memory usage during extended sessions
- **Domain**: Universal Links require proper AASA file hosting and Apple verification

## Support

For Screen Time API documentation:
- [Family Controls Framework](https://developer.apple.com/documentation/familycontrols)
- [ManagedSettings Framework](https://developer.apple.com/documentation/managedsettings)
