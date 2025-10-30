# Drift Design System - Quick Setup Guide

## ✅ Completed
The core design system files have been created:
- `DesignTokens.swift` - Colors, spacing, typography, shadows
- `Typography.swift` - Text style modifiers
- `LayoutExtensions.swift` - Padding & spacing helpers
- `ExampleDesignView.swift` - Usage examples

### ✅ Font Integration Complete
- Font file: `FuturaCyrillicBook.ttf` added to `Resources/Fonts/`
- Registered in Xcode Build Settings → Info → "Fonts provided by application"
- Font family name configured: `"Futura PT"`
- All text styles now use Futura PT Book

### ✅ UI Components Library
Reusable components built with the design system:
- `PillBadge.swift` - Status indicator with dot and text
- `SlideIndicator.swift` - Page indicator dots for navigation
- `BottomPresetSlider.swift` - Horizontal preset carousel
- `StatCard.swift` - Generic analytics card with ViewBuilder pattern
- `ViewAllButton.swift` - Action button with chevron

### ✅ App Pages
Complete UI pages implemented:
- `MainContainerView` - Swipeable 3-page navigation coordinator
- `HomePage` - Centered image with pill badge and preset slider
- `AnalyticsPage` - 2x2 grid statistics layout
- `SettingsPage` - Placeholder for settings

---

## 🔧 Optional Enhancements

### 1. Phosphor Icons Integration

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
- `.heading1()` - 28pt, -0.04 tracking (Futura PT)
- `.heading2()` - 22pt, -0.02 tracking (Futura PT)
- `.body()` - 20pt, 1.6 line height (Futura PT)
- `.bodySmall()` - 18pt, 1.4 line height (Futura PT)

### Spacing (VStack/HStack)
- `DesignTokens.Spacing.xxxLarge` - 32px
- `DesignTokens.Spacing.xxLarge` - 24px
- `DesignTokens.Spacing.xLarge` - 16px (standard)
- `DesignTokens.Spacing.large` - 8px
- `DesignTokens.Spacing.medium` - 4px

### Shadows
- `DesignTokens.Shadow.color` - Black @ 12% opacity
- `DesignTokens.Shadow.radius` - 6px
- `DesignTokens.Shadow.x` - 0px
- `DesignTokens.Shadow.y` - 3px

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
