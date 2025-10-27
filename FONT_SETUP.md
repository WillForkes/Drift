# Futura PT Font Integration Guide

## Step 1: Add Font Files to Xcode

1. **Locate your Futura PT Book font file** (should be `.ttf` or `.otf` format)
   - File name should be something like: `FuturaPT-Book.ttf` or `FuturaPT-Book.otf`

2. **Drag the font file into Xcode:**
   - Open your Drift project in Xcode
   - In the Project Navigator (left sidebar), right-click on the `Drift` folder
   - Select "Add Files to Drift..."
   - Select your Futura PT Book font file
   - **IMPORTANT:** Make sure "Copy items if needed" is checked
   - Make sure "Drift" target is checked
   - Click "Add"

3. **Verify the font was added:**
   - Click on the font file in Xcode
   - In the File Inspector (right sidebar), verify that "Target Membership" shows "Drift" is checked

---

## Step 2: Register Font in Info.plist

1. **Open `Drift/Info.plist`** (if it doesn't exist, you may need to add font info to the project's Info tab)

2. **Add the font to Info.plist:**
   - Right-click in the Info.plist file → "Add Row"
   - Add key: `Fonts provided by application` (or `UIAppFonts`)
   - This creates an Array
   - Click the arrow to expand it
   - Add Item 0 (String): `FuturaPT-Book.ttf` (use your actual filename)

**Alternatively, add this to Info.plist as XML:**
```xml
<key>UIAppFonts</key>
<array>
    <string>FuturaPT-Book.ttf</string>
</array>
```

---

## Step 3: Verify Font Name

The font name used in code (`FuturaPT-Book`) may differ from the filename. To verify:

**Add this temporary code** to any view or `DriftApp.swift` init:
```swift
// List all available fonts
for family in UIFont.familyNames.sorted() {
    let names = UIFont.fontNames(forFamilyName: family)
    print("Family: \(family) - Fonts: \(names)")
}
```

**Run the app** and check the console output. Look for "Futura" and find the exact font name.

**Common variations:**
- `FuturaPT-Book`
- `Futura PT-Book`
- `FuturaPT-BookOblique`

**Update `DesignTokens.swift`** if the name is different:
```swift
static let fontFamily = "ActualFontName" // Replace with actual name from console
```

---

## Step 4: Test Font Integration

1. **Run the app** (⌘R)
2. **Navigate to the Example Design View** (if you created it as a preview)
3. **Check that text renders correctly**
   - If text looks different/wrong, the font isn't loading
   - If text looks correct, font is working!

**To test font in a quick preview:**
```swift
#Preview {
    Text("Drift Focus")
        .font(.custom("FuturaPT-Book", size: 26))
}
```

If this shows the correct font, your integration is successful!

---

## Fallback Behavior

If Futura PT Book isn't available, the design system will fall back to the system font. This ensures the app always works, even during development without the font installed.

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
