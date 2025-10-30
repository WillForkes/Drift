# Futura PT Font Integration Guide

## ✅ Font Integration Complete

The Futura PT Book font has been successfully integrated into the project:
- **Font file**: `FuturaCyrillicBook.ttf`
- **Location**: `Drift/Resources/Fonts/`
- **Font family name**: `"Futura PT"`
- **Font name**: `"FuturaCyrillicBook"`

---

## Setup Steps (Already Completed)

### Step 1: Add Font Files to Xcode ✅

1. **Located the font file**: `FuturaCyrillicBook.ttf`
2. **Added to project**: Located in `Resources/Fonts/` folder
3. **Target membership**: Drift target is checked

### Step 2: Register Font ✅

**Method used**: Xcode Build Settings (more reliable than Info.plist)

1. Navigate to: **Target → Info → Custom iOS Target Properties**
2. Add to **"Fonts provided by application"** array
3. Value: `FuturaCyrillicBook.ttf`

This method is more reliable than editing Info.plist directly and ensures the font is registered in the built app bundle.

### Step 3: Verify Font Name ✅

The font was verified using debug code in `DriftApp.init()`:

```swift
for family in UIFont.familyNames.sorted() {
    let names = UIFont.fontNames(forFamilyName: family)
    print("Family: \(family) - Fonts: \(names)")
}
```

**Console output confirmed**:
```
Family: Futura PT - Fonts: ["FuturaCyrillicBook"]
```

**Updated in `DesignTokens.swift`**:
```swift
static let fontFamily = "Futura PT"  // Correct family name
```

Note: The font family name is `"Futura PT"`, not `"FuturaCyrillicBook"` (which is the individual font name within the family).

### Step 4: Test Font Integration ✅

Font integration is complete and working. All text in the app now uses Futura PT Book:

- HomePage: "Tap drift to activate" heading
- AnalyticsPage: "Your Analytics" title and all card text
- All components: PillBadge, StatCard, ViewAllButton, etc.

**Quick test in preview:**
```swift
#Preview {
    Text("Drift Focus")
        .font(.custom("Futura PT", size: 28))
}
```

---

## Usage in Code

To use the custom font throughout the app, use the design system modifiers:

```swift
Text("Focus Session")
    .heading1()  // Uses Futura PT at 28pt

Text("Details here")
    .body()  // Uses Futura PT at 20pt
```

These modifiers automatically apply the correct font family from `DesignTokens.Typography.fontFamily`.

---

## Troubleshooting

**Font not showing:**
1. Verify font file is in project (visible in Project Navigator)
2. Verify Target Membership is checked for "Drift"
3. Verify Info.plist has correct filename (case-sensitive!)
4. Verify font name matches (use the debug print method above)
5. Clean build folder: Product → Clean Build Folder (⇧⌘K)
6. Rebuild and run

**Wrong font rendering:**
- Double-check the exact font name using the debug print
- Update `DesignTokens.Typography.fontFamily` with correct name

---

## Debugging Notes (Historical)

During initial setup, we encountered an issue where the font wasn't appearing in the console output. The problem was:

**Issue**: UIAppFonts in source Info.plist wasn't making it into the built app bundle's Info.plist

**Solution**: Register the font directly in Xcode's Build Settings:
- Target → Info tab → Custom iOS Target Properties
- Add "Fonts provided by application" array entry
- This ensures it appears in the built bundle's Info.plist

**Key Learning**: The font family name (`"Futura PT"`) differs from both the filename (`FuturaCyrillicBook.ttf`) and the individual font name (`"FuturaCyrillicBook"`). Always verify with the debug print script.
