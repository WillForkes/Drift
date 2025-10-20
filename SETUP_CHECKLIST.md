# Drift - Xcode Setup Checklist

Use this checklist to configure the Xcode project after the skeleton code has been generated.

## ✅ Setup Checklist

### 1. Add Source Files to Xcode Project

- [ ] Open `Drift.xcodeproj` in Xcode
- [ ] Verify the following files are in the Drift target:
  - [ ] `FocusSessionManager.swift`
  - [ ] `SettingsView.swift`
  - [ ] `DriftApp.swift` (updated)
  - [ ] `ContentView.swift` (updated)
  - [ ] `Drift.entitlements`
  - [ ] `Info.plist`
- [ ] Confirm `Item.swift` has been removed

### 2. Create Shield Configuration Extension Target

- [ ] In Xcode: **File > New > Target**
- [ ] Select **iOS > App Extension > Shield Configuration Extension**
- [ ] Name: `DriftShieldConfiguration`
- [ ] Language: Swift
- [ ] Set deployment target: iOS 17.0+
- [ ] Click **Finish** (don't activate scheme if asked)

### 3. Add Extension Files

- [ ] Add `ShieldConfigurationExtension.swift` to the `DriftShieldConfiguration` target
- [ ] Add `Info.plist` to the `DriftShieldConfiguration` target
- [ ] Verify bundle identifier is `<your-bundle-id>.DriftShieldConfiguration`

### 4. Configure Main App Target

#### Signing & Capabilities
- [ ] Select the **Drift** target
- [ ] Go to **Signing & Capabilities** tab
- [ ] Add **Family Controls** capability (if not present)
- [ ] Add **Associated Domains** capability (if not present)
  - [ ] Add entry: `applinks:drift.app` (or your domain)
- [ ] Verify entitlements file is set to `Drift/Drift.entitlements`

#### General
- [ ] Set minimum deployment target to **iOS 17.0**
- [ ] Verify team and bundle identifier are correct

#### Build Settings
- [ ] Search for "Entitlements"
- [ ] Verify **Code Signing Entitlements** is set to `Drift/Drift.entitlements`

### 5. Configure Shield Configuration Extension Target

- [ ] Select the **DriftShieldConfiguration** target
- [ ] **General** tab:
  - [ ] Minimum deployment target: iOS 17.0
  - [ ] Bundle identifier: `<main-bundle>.DriftShieldConfiguration`
- [ ] **Build Settings** tab:
  - [ ] Product Module Name: `DriftShieldConfiguration`
- [ ] **Signing & Capabilities** tab:
  - [ ] Ensure signing is configured with same team

### 6. Universal Links Setup (for NFC)

Choose one option:

#### Option A: Use Your Own Domain
- [ ] Have access to a domain you control
- [ ] Create `apple-app-site-association` file:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "<TEAM_ID>.<BUNDLE_ID>",
        "paths": ["/focus"]
      }
    ]
  }
}
```
- [ ] Host file at `https://yourdomain.com/.well-known/apple-app-site-association`
- [ ] Update `Drift.entitlements`: `applinks:yourdomain.com`
- [ ] Update `SettingsView.swift`: Change URL in NFC setup instructions

#### Option B: Test Without Domain (Development)
- [ ] Skip domain setup for now
- [ ] Use test button in app for development
- [ ] Set up domain before production release

### 7. Build and Test

- [ ] Select a physical device (not simulator - Screen Time APIs don't work in simulator)
- [ ] Build the project (**⌘B**)
- [ ] Fix any build errors (likely need to update provisioning)
- [ ] Run the app (**⌘R**)

### 8. First Run Testing

- [ ] App launches successfully
- [ ] Tap "Enable App Blocking" button
- [ ] Grant Screen Time authorization in iOS Settings
- [ ] Return to app
- [ ] Tap settings gear icon
- [ ] Tap "Select Apps to Block"
- [ ] FamilyActivityPicker appears
- [ ] Select a few test apps
- [ ] Return to main screen
- [ ] Tap "Start Session (Test)"
- [ ] Session indicator turns green
- [ ] Try opening a blocked app - should show shield message
- [ ] Tap "End Session (Test)"
- [ ] Session indicator turns gray
- [ ] Blocked apps are now accessible

### 9. NFC Testing (Optional, requires physical NFC tag)

- [ ] Have an NFC tag (NTAG213 or similar)
- [ ] Download an NFC writing app (e.g., NFC Tools)
- [ ] Write Universal Link URL to tag: `https://yourdomain.com/focus`
- [ ] Tap phone on tag
- [ ] App should toggle focus session
- [ ] Test multiple taps to ensure toggle works

## Common Issues & Solutions

### Build Errors

**Error: "No such module 'FamilyControls'"**
- Solution: Ensure deployment target is iOS 17.0+ and you're building for a physical device

**Error: Entitlements issues**
- Solution: Check that entitlements file is correctly referenced in Build Settings
- Solution: Ensure you have correct provisioning profile with Family Controls capability

**Error: "Cannot find 'SettingsView' in scope"**
- Solution: Verify `SettingsView.swift` is added to the Drift target (not the extension)

### Runtime Issues

**Authorization request doesn't appear**
- Solution: Check that Family Controls capability is properly configured
- Solution: Ensure running on physical device (not simulator)
- Solution: Check Console.app for authorization-related errors

**Apps not being blocked**
- Solution: Verify apps were selected in Settings
- Solution: Check authorization was granted
- Solution: Force quit and restart the app
- Solution: Check device restrictions in iOS Settings

**NFC tag not triggering app**
- Solution: Verify AASA file is hosted correctly (test with curl)
- Solution: Check Associated Domains entitlement matches domain
- Solution: Wait 24 hours for CDN propagation after AASA changes
- Solution: Ensure iPhone model supports background NFC reading (XS or later)

**Shield message not showing custom text**
- Solution: Verify Shield Configuration extension is properly installed
- Solution: Check extension's bundle identifier and Info.plist
- Solution: Rebuild and reinstall the app

### Testing Tips

1. **Use Console.app** on Mac to view device logs while testing
2. **Check Screen Time settings** in iOS Settings to see active restrictions
3. **Force quit and relaunch** after making changes to blocking configuration
4. **Test with social media apps** (Instagram, Twitter, etc.) as they're easy to verify
5. **Verify session persistence** by force quitting app during active session

## Deployment Checklist (Before App Store)

- [ ] Replace `drift.app` with actual domain throughout codebase
- [ ] Set up and test Universal Links with production domain
- [ ] Configure actual NFC tag with production URL
- [ ] Remove or hide test button in production build
- [ ] Add App Store assets (screenshots, description, etc.)
- [ ] Create Privacy Policy (required for Screen Time API)
- [ ] Test on multiple iOS versions (17.0+)
- [ ] Test on multiple device models
- [ ] Submit for App Store review

## Need Help?

- Review `README.md` for detailed architecture documentation
- Check Apple's [Family Controls documentation](https://developer.apple.com/documentation/familycontrols)
- Search for error messages in Apple Developer Forums
- Ensure all prerequisites (iOS 17+, physical device, proper entitlements) are met
