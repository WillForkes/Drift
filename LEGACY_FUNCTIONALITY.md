# Drift Legacy Functionality Documentation

This document details all the **functional features** implemented in the Drift app's core managers and legacy UI views. These features are fully working and ready to be integrated into the new design system pages.

---

## Overview

The legacy implementation includes complete, working functionality for:
- **NFC-triggered focus sessions** via Universal Links
- **App blocking** using iOS Screen Time API
- **Session analytics** with streaks and daily statistics
- **Parental controls** with secure passcode protection
- **Multi-tag support** for registering multiple NFC tags
- **Preset management** for different app blocking configurations

All data is stored locally using **UserDefaults** (for preferences) and **iOS Keychain** (for sensitive passcode data).

---

## Core Managers

### 1. FocusSessionManager

**Location**: `Core/Managers/FocusSessionManager.swift`

**Purpose**: Central manager for focus session state and app blocking.

#### Key Features

- **Session State Management**
  - `isSessionActive`: Published boolean tracking current session state
  - `currentPreset`: Currently selected preset (Social Media, Work, or All)
  - Persistent session state (survives app termination and device restarts)

- **Screen Time Authorization**
  - `requestAuthorization()`: Request Screen Time permission from iOS
  - `isAuthorized`: Published boolean tracking authorization status
  - Uses `FamilyControls.AuthorizationCenter`

- **App Blocking**
  - Applies blocking rules via `ManagedSettingsStore.shield`
  - Supports three modes:
    1. **Social Media preset**: Blocks specific user-selected apps
    2. **Work preset**: Blocks different user-selected apps
    3. **All preset**: Blocks ALL apps including Drift itself
  - Blocking persists even if app is force-quit

- **Preset Management**
  - Three built-in presets: Social Media, Work, All
  - Each preset stores `FamilyActivitySelection` (apps/categories/domains to block)
  - `selectPreset()`: Switch active preset
  - `updatePreset()`: Configure which apps a preset blocks
  - Validates presets are configured before allowing sessions

- **Integration with Analytics**
  - Automatically calls `AnalyticsManager.startSession()` when session starts
  - Automatically calls `AnalyticsManager.stopSession()` when session ends

#### Persistence

- **Session state**: `drift.session.active` (UserDefaults)
- **Presets**: `drift.presets` (UserDefaults, JSON encoded)
- **Current preset**: `drift.current.preset` (UserDefaults, JSON encoded)

#### Key Methods

```swift
func toggleSession() // Toggle session on/off
func startSession() // Start a session
func stopSession() // Stop a session
func requestAuthorization() async throws // Request Screen Time permission
func selectPreset(_ preset: FocusPreset) // Select preset for sessions
func updatePreset(_ preset: FocusPreset, selection: FamilyActivitySelection) // Configure preset apps
```

---

### 2. AnalyticsManager

**Location**: `Core/Managers/AnalyticsManager.swift`

**Purpose**: Track and analyze focus session history.

#### Key Features

- **Session Tracking**
  - Records start time, end time, duration, and preset name for each session
  - `FocusSession` model with UUID, timestamps, and preset info
  - Automatic tracking when `FocusSessionManager` starts/stops sessions

- **Statistics Calculations**
  - **Current Streak**: Consecutive days with at least one completed session
    - Includes 1-day grace period (can skip yesterday and streak continues)
    - Maximum 365 days (prevents infinite loops)
  - **Today's Focus Time**: Total duration of sessions started today
  - **Daily Stats**: Aggregated focus time and session count for last N days
  - **Last Session**: Most recent completed session with duration

- **Data Management**
  - Auto-prunes sessions older than 90 days to prevent unlimited growth
  - All sessions stored as JSON in UserDefaults
  - Loads sessions on manager initialization

#### Data Models

**FocusSession**:
```swift
struct FocusSession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    let presetName: String
    var duration: TimeInterval // Computed: endTime - startTime
}
```

**DailyStats**:
```swift
struct DailyStats: Identifiable {
    let date: Date
    let totalFocusedTime: TimeInterval
    let sessionCount: Int
    var dateString: String // Formatted "Jan 1, 2024"
    var formattedTime: String // "2h 15m"
}
```

#### Persistence

- **Sessions**: `drift.analytics.sessions` (UserDefaults, JSON encoded)
- **Last session date**: `drift.analytics.lastSessionDate` (UserDefaults)

#### Key Methods

```swift
func startSession(presetName: String) // Begin tracking new session
func stopSession() // End current session and save it
func getLastSession() -> FocusSession? // Get most recent session
func getDailyStats(days: Int = 30) -> [DailyStats] // Get stats for last N days
func getTodaysFocusedTime() -> TimeInterval // Total focus time today
func getCurrentStreak() -> Int // Calculate consecutive day streak
```

---

### 3. ParentalControlsManager

**Location**: `Core/Managers/ParentalControlsManager.swift`

**Purpose**: Secure passcode protection to prevent ending sessions.

#### Key Features

- **4-Digit PIN Protection**
  - Must be exactly 4 numeric digits
  - Stored securely in iOS Keychain (encrypted)
  - Required to stop sessions when enabled

- **Security Question Recovery**
  - 5 predefined security questions:
    - "What was the name of your first pet?"
    - "What city were you born in?"
    - "What is your mother's maiden name?"
    - "What was the name of your first school?"
    - "What is your favorite book?"
  - Answer stored in Keychain (case-insensitive)
  - Used to reset forgotten passcode

- **Setup & Management**
  - `setupPasscode()`: Configure passcode, question, and answer
  - `verifyPasscode()`: Check if entered passcode is correct
  - `verifySecurityAnswer()`: Check if security answer is correct (for recovery)
  - `resetPasscode()`: Change passcode after verification
  - `disable()`: Turn off parental controls and clear keychain data

- **State Management**
  - `isEnabled`: Published boolean tracking if parental controls are active
  - Persists to UserDefaults

#### Security Implementation

Uses iOS Keychain (`Security` framework) for secure storage:
- `kSecClassGenericPassword`: Password storage class
- `kSecAttrAccount`: Key identifier
- All sensitive data encrypted by iOS

#### Persistence

- **Enabled state**: `drift.parental.enabled` (UserDefaults)
- **Passcode**: `drift.parental.passcode` (iOS Keychain)
- **Security question**: `drift.parental.question` (iOS Keychain)
- **Security answer**: `drift.parental.answer` (iOS Keychain, lowercased)

#### Key Methods

```swift
func setupPasscode(_ passcode: String, question: String, answer: String) -> Bool
func verifyPasscode(_ passcode: String) -> Bool
func verifySecurityAnswer(_ answer: String) -> Bool
func getSecurityQuestion() -> String?
func resetPasscode(_ newPasscode: String) -> Bool
func disable() // Clear all data
```

---

### 4. DriftTagManager

**Location**: `Core/Managers/DriftTagManager.swift`

**Purpose**: Manage multiple registered NFC tags with unique configurations.

#### Key Features

- **Multi-Tag Registration**
  - Each tag has unique ID (from URL parameter, e.g., "1234")
  - User-assigned label (e.g., "Kitchen", "Office Desk")
  - Assigned preset (Social Media, Work, or All)
  - Date added timestamp

- **Tag Management**
  - Register new tags with label and preset assignment
  - Update existing tag labels and preset assignments
  - Delete tags from registry
  - Check if tag ID is registered
  - Get tag by ID

- **Persistence**
  - All tags stored as JSON array in UserDefaults
  - Loads automatically on manager initialization

#### Data Model

**DriftTag**:
```swift
struct DriftTag: Codable, Identifiable {
    let id: String // Unique ID from URL (e.g., "1234")
    var label: String // User name (e.g., "Kitchen")
    var presetId: String // Which preset to use
    let dateAdded: Date
}
```

#### Persistence

- **Tags**: `drift.tags` (UserDefaults, JSON encoded)

#### Key Methods

```swift
func registerTag(id: String, label: String, presetId: String)
func updateTag(id: String, label: String, presetId: String)
func deleteTag(id: String)
func getTag(by id: String) -> DriftTag?
func isRegistered(id: String) -> Bool
```

---

## NFC & Universal Link Handling

**Location**: `App/DriftApp.swift`

### How It Works

1. **NFC Tag Configuration**
   - Physical NFC tags are programmed with Universal Link URLs
   - Format: `https://get-drift.app/focus?id=XXXX`
   - Each tag has unique ID parameter (e.g., `?id=1234`, `?id=5678`)

2. **URL Handling Flow**
   ```
   User taps NFC tag
   → iOS reads URL from tag
   → Opens Drift app via Universal Link
   → handleUniversalLink() called with URL
   → Parse tag ID from query parameter
   → Check if tag is registered
   ```

3. **First-Time Tag Setup**
   - If tag ID is NOT registered:
     - Post `nfcTagNeedsSetup` notification with tag ID
     - Show `TagSetupView` sheet
     - User assigns label and preset
     - Tag registered to `DriftTagManager`
     - Session starts automatically with assigned preset

4. **Registered Tag Behavior**
   - If tag ID IS registered:
     - Retrieve tag's assigned preset
     - **Starting session**: Select preset and start
     - **Stopping session**:
       - If parental controls enabled: Post `nfcStopRequested` notification (shows passcode entry)
       - If parental controls disabled: Stop session immediately

5. **Error Handling**
   - Missing ID parameter: Post `nfcTagMissingId` notification (shows error alert)
   - Invalid host/path: Ignore URL

### NotificationCenter Events

Custom notification names for coordinating NFC actions:

```swift
extension Notification.Name {
    static let nfcStopRequested // User wants to stop session (show passcode if enabled)
    static let nfcTagNeedsSetup // Unregistered tag detected (show setup flow)
    static let nfcTagMissingId // Tag missing ID parameter (show error)
}
```

### Key Implementation

```swift
private func handleUniversalLink(_ url: URL) {
    // Validate URL: https://get-drift.app/focus?id=1234
    guard url.host == "get-drift.app", url.path == "/focus" else { return }

    // Extract tag ID
    guard let tagId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
        NotificationCenter.default.post(name: .nfcTagMissingId, object: nil)
        return
    }

    // Check registration status
    if let tag = tagManager.getTag(by: tagId) {
        handleRegisteredTag(tag) // Toggle session with tag's preset
    } else {
        NotificationCenter.default.post(name: .nfcTagNeedsSetup, object: tagId)
    }
}
```

---

## Legacy UI Views

These views implement the complete functionality with the original design (pre-Futura PT design system).

### ContentView.swift

**Purpose**: Main screen with session controls.

**Features**:
- Session status indicator (green circle = active, gray = inactive)
- SF Symbols icons (bolt.fill when active, bolt.slash.fill when inactive)
- "Focus Active" / "Not Focused" status text
- Current preset name display
- "Enable App Blocking" button (requests Screen Time authorization)
- "Start Session (Test)" / "End Session (Test)" button for development testing
- Navigation bar with analytics and settings buttons
- Sheet presentations for SettingsView and AnalyticsView
- Passcode entry when stopping session (if parental controls enabled)
- Forgot passcode flow with security question recovery
- Tag setup flow for unregistered tags
- Preset configuration validation (shows alert if preset not configured)
- Error alerts for authorization failures and invalid tags

**NotificationCenter Listeners**:
- `nfcStopRequested`: Shows passcode entry sheet
- `nfcTagNeedsSetup`: Shows tag setup sheet with tag ID
- `nfcTagMissingId`: Shows invalid tag error alert

### SettingsView.swift

**Purpose**: Configure presets, parental controls, and manage tags.

**Features**:
- **Presets Section**:
  - List of all presets (Social Media, Work, All)
  - Checkmark on currently selected preset
  - "Not configured" warning for presets without apps selected
  - "Blocks all apps" indicator for All preset
  - Tap to select preset and configure (shows `FamilyActivityPicker`)
- **Parental Controls Section**:
  - Enable/Disable toggle with status display
  - "Set Up" button (shows `ParentalControlsSetupView`)
  - "Disable" button with confirmation alert
  - Footer explaining passcode requirement
- **Drift Tags Section**:
  - "My Drifts" button showing tag count
  - Opens `RegisteredTagsView` to manage tags
- **About Section**:
  - Version number display (1.0.0)
- **FamilyActivityPicker Integration**:
  - Native iOS picker for selecting apps/categories to block
  - Updates preset selection when changed

### AnalyticsView.swift

**Purpose**: Display focus session statistics.

**Features**:
- **Summary Stats Cards**:
  - Current Streak (flame icon, orange)
  - Today (clock icon, blue) - formatted as "Xh Ym"
  - Last Session (bolt icon, green) - duration and preset name
- **Last 30 Days History**:
  - Scrollable list of daily stats
  - Each row shows: date, session count, total time
  - "No sessions" indicator for days with no focus time
- **Duration Formatting**:
  - Hours and minutes display (e.g., "2h 15m")
  - Minutes only if less than 1 hour (e.g., "45m")
  - "0m" if no time recorded

---

## Additional Legacy Views

### ParentalControls/ParentalControlsSetupView.swift
Multi-step flow for setting up passcode and security question.

### ParentalControls/PasscodeEntryView.swift
4-digit PIN entry interface with keypad.

### ParentalControls/SecurityQuestionRecoveryView.swift
Recovery flow using security question to reset forgotten passcode.

### Tags/RegisteredTagsView.swift
List view for managing all registered NFC tags (edit labels, change presets, delete).

### Tags/TagSetupView.swift
Setup flow for newly detected tags (assign label and preset).

---

## Data Persistence Summary

| Data Type | Storage Method | Key/Location |
|-----------|---------------|--------------|
| Session active state | UserDefaults | `drift.session.active` |
| Presets configuration | UserDefaults (JSON) | `drift.presets` |
| Current preset | UserDefaults (JSON) | `drift.current.preset` |
| Session history | UserDefaults (JSON) | `drift.analytics.sessions` |
| Last session date | UserDefaults | `drift.analytics.lastSessionDate` |
| Registered tags | UserDefaults (JSON) | `drift.tags` |
| Parental controls enabled | UserDefaults | `drift.parental.enabled` |
| Passcode | iOS Keychain (encrypted) | `drift.parental.passcode` |
| Security question | iOS Keychain (encrypted) | `drift.parental.question` |
| Security answer | iOS Keychain (encrypted) | `drift.parental.answer` |

---

## Integration Notes for New UI

### What's Ready to Use

All managers are fully functional and can be integrated into the new design pages:

1. **HomePage** can integrate:
   - `FocusSessionManager.shared` for session toggle
   - `PillBadge` component can show `isSessionActive` state
   - Bottom preset slider can call `selectPreset()`

2. **AnalyticsPage** can integrate:
   - `AnalyticsManager.shared.getCurrentStreak()` for streak card
   - `AnalyticsManager.shared.getTodaysFocusedTime()` for today card
   - `AnalyticsManager.shared.getDailyStats()` for taps per day data

3. **SettingsPage** can integrate:
   - `FocusSessionManager.shared.presets` for preset list
   - `FamilyActivityPicker` for app selection
   - `ParentalControlsManager.shared` for passcode setup
   - `DriftTagManager.shared.tags` for tag management

### State Management

All managers are `@MainActor` singletons with `@Published` properties:

```swift
@StateObject private var sessionManager = FocusSessionManager.shared
@StateObject private var analytics = AnalyticsManager.shared
@StateObject private var parentalControls = ParentalControlsManager.shared
@StateObject private var tagManager = DriftTagManager.shared
```

Views automatically update when published properties change (e.g., `isSessionActive`, `sessions`, `isEnabled`, `tags`).

---

## Testing the Functionality

### Without Physical NFC Tag

Use the test button in `ContentView`:
- Tap "Start Session (Test)" to begin blocking apps
- Tap "End Session (Test)" to stop blocking

### With Physical NFC Tag

1. Program tag with URL: `https://get-drift.app/focus?id=XXXX` (replace XXXX with unique ID)
2. Tap phone to tag
3. First tap: Shows setup flow (assign label and preset)
4. Subsequent taps: Toggles session on/off

**Note**: Universal Links only work on physical devices in TestFlight/App Store builds. Development builds may open Safari instead.

---

## Known Limitations

- **Simulator**: Screen Time APIs don't work in iOS Simulator (requires physical device)
- **Authorization**: User must grant Screen Time permission for blocking to work
- **NFC Requirements**: iPhone XS or later for background NFC tag reading
- **Universal Links**: Require proper AASA file hosting and domain verification at `https://get-drift.app/.well-known/apple-app-site-association`

---

## Next Steps

To integrate this functionality into the new design system pages:

1. Replace placeholder data in `AnalyticsPage` with real `AnalyticsManager` data
2. Wire up `HomePage` preset slider to `FocusSessionManager.selectPreset()`
3. Add session toggle functionality to `HomePage` pill badge tap
4. Build `SettingsPage` with preset configuration using `FamilyActivityPicker`
5. Add NFC notification handlers to new views
6. Integrate parental controls passcode flow
7. Connect tag management UI

All the business logic is complete—just needs to be connected to the new beautiful UI!
