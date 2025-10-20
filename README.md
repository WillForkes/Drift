# Drift - Focus Ritual iOS App

A minimalist focus ritual app that uses NFC tags to help users enter and exit focus sessions by blocking distracting apps.

## Overview

Drift is a premium iOS app that enables users to reduce distractions by temporarily blocking access to configurable apps. Focus sessions are triggered by tapping an NFC tag, creating a physical ritual around focused work.

### Core Features

- **NFC-Triggered Sessions**: Tap an NFC tag to start/stop focus sessions
- **App Blocking**: Blocks access to pre-selected apps during focus sessions
- **Persistent Sessions**: Sessions survive app termination and device restarts
- **Custom Shield Messages**: Shows "This app is a distraction" when blocked apps are accessed
- **Fully Local**: No backend required, all data stored on device

## Project Structure

```
Drift/
├── Drift/
│   ├── DriftApp.swift              # Main app entry point with Universal Link handling
│   ├── ContentView.swift            # Main screen with session status and controls
│   ├── SettingsView.swift           # Settings screen with app selection
│   ├── FocusSessionManager.swift    # Core session management and Screen Time integration
│   ├── Drift.entitlements           # Required entitlements
│   └── Info.plist                   # App configuration
│
└── DriftShieldConfiguration/
    ├── ShieldConfigurationExtension.swift  # Custom blocked app messages
    └── Info.plist                          # Extension configuration
```

## Technical Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Required Frameworks**:
  - SwiftUI
  - FamilyControls
  - ManagedSettings
  - ManagedSettingsUI

### Entitlements

The following entitlements are required and configured in `Drift.entitlements`:
- `com.apple.developer.family-controls` - For app blocking
- `com.apple.developer.device-activity` - For device activity monitoring
- `com.apple.developer.associated-domains` - For Universal Links (NFC)

## Xcode Setup Instructions

### 1. Add Files to Xcode Project

The source files have been created but need to be added to the Xcode project:

1. Open `Drift.xcodeproj` in Xcode
2. Add the following new files to the Drift target:
   - `FocusSessionManager.swift`
   - `SettingsView.swift`
3. Ensure `Drift.entitlements` and `Info.plist` are included in the target

### 2. Create Shield Configuration Extension Target

The Shield Configuration extension requires a separate target:

1. In Xcode, go to **File > New > Target**
2. Choose **iOS > App Extension > Shield Configuration Extension**
3. Name it `DriftShieldConfiguration`
4. Set the same team and bundle identifier prefix
5. Add the files from `DriftShieldConfiguration/` folder to this target
6. Ensure the extension's deployment target is iOS 17.0+

### 3. Configure Project Settings

#### Main App Target (Drift)

1. **General Tab**:
   - Set minimum deployment target to iOS 17.0
   - Ensure `Drift.entitlements` is selected in Signing & Capabilities

2. **Signing & Capabilities Tab**:
   - Add **Family Controls** capability
   - Add **Associated Domains** capability
     - Add domain: `applinks:drift.app`
   - Ensure entitlements file is `Drift/Drift.entitlements`

3. **Info Tab**:
   - Verify NFC and Universal Link configurations from `Info.plist`

#### Shield Configuration Extension Target

1. **General Tab**:
   - Set minimum deployment target to iOS 17.0
   - Ensure bundle identifier is `<main-bundle-id>.DriftShieldConfiguration`

2. **Build Settings**:
   - Set **Product Module Name** to `DriftShieldConfiguration`

### 4. Remove Template Files

Delete these template files that are no longer needed:
- `Item.swift` (SwiftData template)

Update imports in `DriftApp.swift` if needed (already updated in provided code).

## Universal Link Configuration

### Domain Setup

For NFC to work, you need to configure the Universal Link domain:

1. **Host the `apple-app-site-association` file** at `https://drift.app/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.yourcompany.Drift",
        "paths": ["/focus"]
      }
    ]
  }
}
```

Replace `TEAMID` and bundle identifier with your actual values.

2. **Alternative for Development**: Use a custom domain you control or test with deep links in the simulator.

### NFC Tag Setup

To use with a physical NFC tag:

1. Get a writable NFC tag (NTAG213/215/216)
2. Use an NFC writing app (like NFC Tools)
3. Write the Universal Link URL: `https://drift.app/focus`
4. Tap the tag with your phone to trigger focus sessions

## Testing

### Without NFC Tag

The app includes a test button on the main screen for development:
- Tap "Start Session (Test)" to begin blocking apps
- Tap "End Session (Test)" to stop blocking

This allows testing without a physical NFC tag or on the iOS Simulator.

### With NFC Tag

On a physical device with a configured NFC tag:
1. Ensure the tag is programmed with `https://drift.app/focus`
2. Tap the phone on the tag to toggle focus sessions
3. The app will start/stop automatically when the tag is detected

## Usage Flow

### First Launch

1. User opens Drift
2. Taps "Enable App Blocking" to request Screen Time authorization
3. Grants permission in iOS Settings when prompted
4. Taps the settings gear icon
5. Selects "Select Apps to Block"
6. Chooses apps from FamilyActivityPicker
7. Returns to main screen

### Starting a Focus Session

**Method 1 - NFC Tag (Production)**:
- Tap phone on configured NFC tag
- App automatically blocks selected apps
- Green indicator shows session is active

**Method 2 - Test Button (Development)**:
- Tap "Start Session (Test)" button
- Session starts immediately

### During a Session

- Selected apps are blocked
- Attempting to open a blocked app shows: "This app is a distraction. Tap your Drift tag to end your focus session."
- Session persists even if:
  - App is closed
  - Phone is restarted
  - App is force-quit

### Ending a Session

- Tap the NFC tag again (or use test button)
- All blocked apps immediately become accessible

## Architecture Notes

### FocusSessionManager

The `FocusSessionManager` is a singleton that:
- Manages session state with `@Published` properties
- Persists state to `UserDefaults`
- Integrates with Screen Time API via `ManagedSettings`
- Restores session on app launch
- Applies/removes app blocking based on user selection

### State Persistence

- **Session State**: Stored in UserDefaults at key `drift.session.active`
- **Blocked Apps**: Stored as encoded `FamilyActivitySelection` at key `drift.blocked.apps`
- Both persist across app launches and device restarts

### Screen Time Integration

- **Authorization**: Requested via `AuthorizationCenter`
- **App Selection**: Uses `FamilyActivityPicker` for user to choose apps
- **Blocking**: Applied via `ManagedSettingsStore.shield` properties
- **Custom Messages**: Provided by `ShieldConfigurationExtension`

## Next Steps

### Required for Production

1. **Configure actual domain** for Universal Links (replace `drift.app`)
2. **Test on physical device** with NFC capability
3. **Design polish** - Update UI with final branding and design
4. **Privacy Policy** - Required for Screen Time API usage
5. **App Store assets** - Screenshots, description, etc.

### Potential Enhancements

- Session analytics/history
- Configurable focus durations
- Multiple focus modes with different app lists
- Widget showing current session status
- Notifications when session starts/ends
- Sound/haptic feedback on tag tap

## Important Notes

- **Testing Limitations**: Screen Time features cannot be tested in the iOS Simulator - requires a physical device
- **Authorization**: Users must grant Screen Time permission for app blocking to work
- **NFC**: Requires iPhone XS or later for background NFC tag reading
- **Domain Verification**: Universal Links require proper AASA file hosting and domain verification

## Support

For issues or questions about the Screen Time API, refer to Apple's documentation:
- [Family Controls Framework](https://developer.apple.com/documentation/familycontrols)
- [ManagedSettings Framework](https://developer.apple.com/documentation/managedsettings)
- [Shield Configuration Extension](https://developer.apple.com/documentation/managedsettingsui)
