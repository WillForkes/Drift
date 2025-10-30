# Drift - Focus Ritual iOS App

A minimalist focus ritual app that transforms phone blocking into a positive, aesthetic experience. Students tap a physical NFC object to enter a sanctuary of focus—no punishment, just intention.

## Why Drift Exists

**The Problem:**
Students are chronically distracted by their phones—social media, notifications, and ambient digital noise fragment attention constantly. Existing "phone blockers" (apps, bricks, lockboxes) feel punitive and gimmicky. They turn work into prison, not flow.

**The Drift Approach:**
Instead of punishing distraction, Drift creates a **desire to focus**. A physical NFC object becomes a cognitive anchor—touching it signals: *"I am now focused."* The ritual is visible, elegant, and identity-affirming. It's not about locking yourself away; it's about creating a perfect working environment.

**Why Now:**
- Students are seeking subtle, tangible anchors for focus amid TikTok/Instagram scroll fatigue
- Rising cultural trend of "aesthetic minimalism + ritual micro-actions" (viral-ready on social platforms)
- Visible objects on desks/dorms signal self-discipline aesthetic, aligning with student identity trends

**Psychology Leveraged:**
1. **Physical Anchoring** — Touching the NFC object triggers a micro cognitive switch
2. **Environmental Cueing** — The object visually defines a "focus zone" without explanation
3. **Peer Signal** — Communicates aesthetic self-discipline, appealing to student social trends

## Product Overview

Drift is a premium iOS app that blocks distracting apps during focus sessions. Sessions are triggered by tapping a physical NFC tag—creating a tangible ritual around focused work that feels intentional, not restrictive.

### Core Features

- **NFC-Triggered Sessions**: Tap an NFC tag to start/stop focus sessions
- **Multi-Tag Support**: Register multiple NFC tags with unique IDs and preset assignments
- **Focus Presets**: Three built-in presets (Social Media, Work, All) with customizable app selections
- **App Blocking**: Blocks access to pre-selected apps during focus sessions using Screen Time API
- **Parental Controls**: Optional 4-digit passcode protection with security question recovery
- **Session Analytics**: Track focus time, streaks, and session history (last 30 days)
- **Persistent Sessions**: Sessions survive app termination and device restarts
- **Custom Shield Messages**: Shows "This app is a distraction" when blocked apps are accessed
- **Swipeable Navigation**: Native iOS swipe gestures between 3 main pages (Analytics, Home, Settings)
- **Design System**: Cohesive design with Futura PT font, custom colors, shadows, and reusable components
- **Fully Local**: No backend required, all data stored securely on device (Keychain + UserDefaults)

## Project Structure

```
Drift/
├── Drift/
│   ├── App/
│   │   └── DriftApp.swift                      # Main app entry point with Universal Link handling
│   │
│   ├── Core/
│   │   ├── Managers/
│   │   │   ├── FocusSessionManager.swift       # Session state & Screen Time integration
│   │   │   ├── ParentalControlsManager.swift   # Passcode & security (Keychain)
│   │   │   ├── DriftTagManager.swift           # NFC tag registration
│   │   │   └── AnalyticsManager.swift          # Session tracking & statistics
│   │   └── Models/
│   │       └── FocusPreset.swift               # Preset data models
│   │
│   ├── Screens/
│   │   ├── Main/
│   │   │   ├── MainContainerView.swift         # Root coordinator with swipeable pages
│   │   │   └── ContentView.swift               # Legacy main screen with session controls
│   │   ├── Home/
│   │   │   └── HomePage.swift                  # Home page with centered image & preset slider
│   │   ├── Analytics/
│   │   │   ├── AnalyticsPage.swift             # New analytics page with 2x2 stats grid
│   │   │   └── AnalyticsView.swift             # Legacy session history & streaks
│   │   ├── Settings/
│   │   │   ├── SettingsPage.swift              # New settings page placeholder
│   │   │   └── SettingsView.swift              # Legacy settings with preset management
│   │   ├── ParentalControls/
│   │   │   ├── ParentalControlsSetupView.swift # Passcode setup flow
│   │   │   └── PasscodeEntryView.swift         # 4-digit PIN entry
│   │   └── Tags/
│   │       ├── RegisteredTagsView.swift        # Manage registered NFC tags
│   │       └── TagSetupView.swift              # Register new NFC tags
│   │
│   ├── Components/
│   │   ├── PillBadge.swift                     # Status indicator badge
│   │   ├── SlideIndicator.swift                # Page indicator dots
│   │   ├── BottomPresetSlider.swift            # Horizontal preset carousel
│   │   ├── StatCard.swift                      # Reusable analytics card
│   │   └── ViewAllButton.swift                 # Action button with arrow icon
│   │
│   ├── DesignSystem/
│   │   ├── DesignTokens.swift                  # Colors, spacing, typography
│   │   ├── Typography.swift                    # Text style modifiers
│   │   ├── LayoutExtensions.swift              # Padding helpers
│   │   └── ExampleDesignView.swift             # Design showcase
│   │
│   └── Resources/
│       ├── Fonts/
│       │   └── FuturaCyrillicBook.ttf          # Futura PT Book font
│       ├── Info.plist                          # App configuration
│       └── Drift.entitlements                  # Required entitlements
│
└── DriftShieldConfiguration/
    ├── ShieldConfigurationExtension.swift      # Custom blocked app messages
    └── Info.plist                              # Extension configuration
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

The following entitlements are required and configured in `Resources/Drift.entitlements`:
- `com.apple.developer.family-controls` - For app blocking (includes device activity in iOS 17+)
- `com.apple.developer.associated-domains` - For Universal Links (NFC tag support)
  - Domain: `applinks:get-drift.app`

**Note**: Family Controls Distribution entitlement requires Apple approval for TestFlight/App Store distribution.

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
     - Add domain: `applinks:get-drift.app`
   - Ensure entitlements file is `Drift/Resources/Drift.entitlements`

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

1. **Host the `apple-app-site-association` file** at `https://get-drift.app/.well-known/apple-app-site-association`:

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

2. **Testing Universal Links**: Universal Links only work properly in TestFlight or App Store builds. Development builds may open Safari instead of the app directly.

### NFC Tag Setup

To use with a physical NFC tag:

1. Get a writable NFC tag (NTAG213/215/216)
2. Use an NFC writing app (like NFC Tools)
3. Write the Universal Link URL with unique ID: `https://get-drift.app/focus?id=XXXX`
   - Each tag should have a unique ID (e.g., `?id=1234`, `?id=5678`)
4. Tap the tag with your phone to trigger the tag registration flow (first time) or toggle sessions (registered tags)

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

## App Structure

### Swipeable Page Navigation

The app uses a native iOS TabView with page style to provide smooth swipe navigation between three main pages:

1. **Analytics Page** (Left) - View focus statistics, streaks, and daily usage
2. **Home Page** (Center) - Main screen with centered image and preset selection
3. **Settings Page** (Right) - Configure presets and app settings

The `MainContainerView` coordinates page navigation with a synced `SlideIndicator` at the top showing the current page.

### Home Page

The home page features a minimalist, centered design:
- **Pill Badge**: Status indicator with "drifting" text and red dot
- **Heading**: "Tap drift to activate" in Futura PT heading1 style
- **Centered Image**: Square image at 60% screen width, positioned absolutely centered
- **Bottom Preset Slider**: Horizontal carousel with Work, Sleep, and Add cards
  - Selected card: Full scale with shadow
  - Unselected cards: 75% scale with reduced opacity
  - Gradient background from accent to background color

### Analytics Page

The analytics page displays user statistics in a 2x2 grid layout:

**Left Column** (2 stacked cards):
- **Current Streak**: Flame icon with day count
- **Today**: Clock icon with minutes tracked

**Right Column** (Full-height card):
- **Taps per Day**: Hand tap icon with list of 6 recent days
- Shows date and tap count for each day
- "View All" button at bottom to see full history

All cards use:
- White background with rounded corners
- Subtle shadow (6px radius, 3px y-offset, 12% opacity)
- Primary color icons (burnt orange)
- Structured layout: Icon → Title → Content

### Reusable Components

**PillBadge**: Status indicator with text and colored dot
- White background, rounded corners
- 5x5px red circle indicator
- Used for showing session status

**SlideIndicator**: Page indicator dots
- 3 horizontal rounded rectangles
- Active page: 2x width, accent color
- Inactive pages: Standard width, 50% opacity accent

**BottomPresetSlider**: Horizontal preset carousel
- Native iOS ScrollTargetBehavior for smooth snapping
- Scale and opacity transitions on scroll
- Gradient background overlay

**StatCard**: Generic analytics card with flexible content
- Uses ViewBuilder pattern for custom content
- Consistent structure: Icon (32pt SF Symbol) → Title → Content
- White background with shadow

**ViewAllButton**: Action button with arrow
- Black background, white text
- Chevron right icon
- Used for navigation to detail views

## Design System

Drift uses a comprehensive design system for consistent, maintainable UI.

### Design Tokens

**Colors** (defined in `DesignSystem/DesignTokens.swift`):
- Background: `#F7F0E9` (warm beige)
- Accent: `#E2B899` (soft peach)
- Primary: `#C86A1C` (burnt orange)
- Text colors with opacity variations

**Typography**:
- Font: Futura PT Book (custom font - FuturaCyrillicBook.ttf)
- Sizes: heading1 (28pt), heading2 (22pt), body (20pt), bodySmall (18pt)
- Custom tracking and line height for each style

**Spacing**:
- xxxLarge: 32px
- xxLarge: 24px
- xLarge: 16px (standard)
- large: 8px
- medium: 4px

**Shadows**:
- Subtle shadow for elevated UI elements
- Color: Black with 12% opacity
- Radius: 6px, Offset: (0, 3)
- Used on cards, selected carousel items, and buttons

### Usage

```swift
// Typography modifiers
Text("Focus Session").heading1()
Text("Details").bodySmall().subtextColor()

// Colors
.background(DesignTokens.Colors.background)
.foregroundColor(DesignTokens.Colors.primary)

// Spacing & Padding
VStack(spacing: DesignTokens.Spacing.standard) { ... }
  .padding(.large)  // Semantic padding
```

See `DesignSystem/ExampleDesignView.swift` for full examples.

For detailed setup instructions, see `DESIGN_SYSTEM_SETUP.md` and `FONT_SETUP.md`.

### Custom Font Setup

The app uses **Futura PT Book** (FuturaCyrillicBook.ttf) as the primary font:

1. **Font File**: Located in `Resources/Fonts/FuturaCyrillicBook.ttf`
2. **Registration**: Font must be registered in Xcode's Build Settings:
   - Navigate to: Target → Info → Custom iOS Target Properties
   - Add to "Fonts provided by application" array
   - Value: `FuturaCyrillicBook.ttf`
3. **Font Family Name**: The actual font family name is `"Futura PT"` (not the filename)
4. **Usage in Code**: `DesignTokens.Typography.fontFamily = "Futura PT"`

**Debugging Font Loading**:
To verify the font loaded correctly, you can temporarily add this to `DriftApp.init()`:
```swift
for family in UIFont.familyNames.sorted() {
    let names = UIFont.fontNames(forFamilyName: family)
    print("Family: \(family) - Fonts: \(names)")
}
```
You should see: `Family: Futura PT - Fonts: ["FuturaCyrillicBook"]`

## Architecture Notes

### App Entry Point

The app launches with `MainContainerView` as the root view (configured in `DriftApp.swift`). This provides the swipeable 3-page navigation structure with Analytics, Home, and Settings pages.

The legacy `ContentView` with functional session controls remains in the project for reference and future integration with the new UI pages.

### FocusSessionManager

The `FocusSessionManager` is a singleton that:
- Manages session state with `@Published` properties
- Handles three presets: Social Media, Work, All
- Integrates with Screen Time API via `ManagedSettings`
- Restores session on app launch
- Applies/removes app blocking based on selected preset
- Validates presets are configured before starting sessions
- Integrates with AnalyticsManager to track sessions

### ParentalControlsManager

Manages passcode protection with secure storage:
- 4-digit PIN stored in iOS Keychain (encrypted)
- Security question/answer for password recovery
- Validates passcode attempts
- Optional feature (can be enabled/disabled)

### DriftTagManager

Handles multiple NFC tag registrations:
- Store tag ID, label, and assigned preset
- Persist tags to UserDefaults
- Support tag editing and deletion
- Each tag can be assigned to a different preset

### AnalyticsManager

Tracks focus session statistics:
- Records session start/end times and preset used
- Calculates daily focus time and total session count
- Computes streaks with 1-day grace period
- Keeps last 90 days of sessions, auto-prunes older data
- All data stored locally in UserDefaults

### State Persistence

- **Session State**: UserDefaults (`drift.session.active`)
- **Presets**: UserDefaults (`drift.presets`) - includes FamilyActivitySelection
- **Tags**: UserDefaults (`drift.tags`)
- **Analytics**: UserDefaults (`drift.analytics.sessions`)
- **Passcode**: iOS Keychain (encrypted, secure)
- All data persists across app launches and device restarts

### Screen Time Integration

- **Authorization**: Requested via `AuthorizationCenter`
- **App Selection**: Uses `FamilyActivityPicker` for user to choose apps
- **Blocking**: Applied via `ManagedSettingsStore.shield` properties
- **Custom Messages**: Provided by `ShieldConfigurationExtension`

## Next Steps

### Required for Production

1. ✅ **Universal Links configured** - Domain: `get-drift.app` with AASA file hosted
2. ✅ **Physical NFC tags written** with unique IDs
3. ⏳ **Family Controls Distribution entitlement** - Awaiting Apple approval (1-3 business days)
4. 🔄 **Design polish** - Apply design system to all views
5. **TestFlight testing** - Test Universal Links in TestFlight build
6. **Privacy Policy** - Required for Screen Time API usage
7. **App Store assets** - Screenshots, description, marketing materials

### Implemented Features

✅ Session analytics/history (functional + new UI)
✅ Multiple focus modes with different app lists (Presets)
✅ Parental controls with passcode protection
✅ Multi-tag support with unique IDs
✅ Design system with custom typography, colors, and shadows
✅ Swipeable 3-page navigation (Analytics, Home, Settings)
✅ Complete home page with centered image and preset slider
✅ Analytics page with 2x2 statistics grid
✅ Reusable component library (StatCard, ViewAllButton, PillBadge, etc.)

### Potential Enhancements

- Configurable focus durations with timers
- Widget showing current session status
- Notifications when session starts/ends
- Sound/haptic feedback on tag tap
- Export analytics data
- Custom preset creation (beyond the 3 defaults)
- Focus session scheduling

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
