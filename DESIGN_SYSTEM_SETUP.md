# Drift Design System - Quick Setup Guide

## ✅ Completed
The core design system files have been created:
- `DesignTokens.swift` - Colors, spacing, typography constants
- `Typography.swift` - Text style modifiers
- `LayoutExtensions.swift` - Padding & spacing helpers
- `ExampleDesignView.swift` - Usage examples

---

## 🔧 Remaining Setup Tasks

### 1. Font Integration (Futura PT Book)

**Quick Steps:**
1. Add `FuturaPT-Book.ttf` to Xcode project (drag & drop, check "Copy items" + "Drift" target)
2. Add to `Info.plist`:
   ```xml
   <key>UIAppFonts</key>
   <array>
       <string>FuturaPT-Book.ttf</string>
   </array>
   ```
3. Verify font name in console (may need to update `DesignTokens.Typography.fontFamily`)

**Full instructions:** See `FONT_SETUP.md`

---

### 2. Phosphor Icons Integration

**Option A: Swift Package (Recommended)**
1. File → Add Package Dependencies
2. Search: `https://github.com/phosphor-swift/phosphor-swift`
3. Add to Drift target
4. Import: `import Phosphor`
5. Use: `Image(systemName: PhosphorIcon.heart.name)`

**Option B: SF Symbols Alternative**
If Phosphor setup is complex, you can use SF Symbols temporarily:
- Replace Phosphor icons with `Image(systemName: "...")`
- Migrate to Phosphor later

---

## 📖 Usage Examples

### Colors
```swift
.background(DesignTokens.Colors.background)
.foregroundColor(DesignTokens.Colors.primary)
```

### Typography
```swift
Text("Focus Session")
    .heading1()

Text("Details here")
    .bodySmall()
    .subtextColor()
```

### Spacing & Padding
```swift
VStack(spacing: DesignTokens.Spacing.standard) {
    Text("Item 1")
    Text("Item 2")
}
.padding(.large)
```

---

## 🎨 Design Tokens Reference

### Colors
- `background` - #F7F0E9
- `accent` - #E2B899
- `primary` - #C86A1C
- `textPrimary` - #000000
- `subtext` - #000000 @ 80%
- `extraSubtext` - #000000 @ 50%
- `whiteText` - #FFFFFF

### Typography
- `.heading1()` - 26pt, -0.04 tracking
- `.heading2()` - 20pt, -0.02 tracking
- `.body()` - 18pt, 1.6 line height
- `.bodySmall()` - 16pt, 1.4 line height

### Spacing (VStack/HStack)
- `DesignTokens.Spacing.huge` - 32px
- `DesignTokens.Spacing.large` - 24px
- `DesignTokens.Spacing.standard` - 16px (most common)
- `DesignTokens.Spacing.compact` - 8px
- `DesignTokens.Spacing.tight` - 4px

### Padding
- `.padding(.large)` - 16px
- `.padding(.medium)` - 8px
- `.padding(.small)` - 4px

---

## 🔍 Testing Your Setup

**View the example:**
1. Build project (⌘B)
2. Preview `ExampleDesignView` or add to navigation
3. Verify colors, typography, and spacing render correctly

**Font verification:**
- If font looks wrong, check `FONT_SETUP.md` troubleshooting
- System font fallback is active until Futura PT is properly integrated

---

## Next Steps

Once font and icons are integrated:
1. Design system is ready to use
2. Begin applying to existing views (when instructed)
3. All design tokens are centralized and type-safe
