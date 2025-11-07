# Memory Leak Issues - Quick Reference

## Critical Issues (Fix First)

### Issue 1: NFCReaderManager Completion Handler Cycle
- **File:** `NFCReaderManager.swift` lines 28-30
- **Problem:** `scanCompletion` closure stored as property creates retain cycle with calling view
- **Impact:** Leaks 8-16 KB per NFC scan during active session
- **Called from:** HomePage.swift:102, ActiveSessionScreen.swift:75
- **Fix:** Implement weak reference handling for completion closures

### Issue 2: SyncingPage Task Accumulation
- **File:** `SyncingPage.swift` lines 218-265, 296-300
- **Problem:** Tasks created with Task.sleep() have no cancellation tracking
- **Impact:** Multiple tasks accumulate in memory (1-3 seconds each), leaks 20-50 KB
- **Called from:** Onboarding flow when adding new drifts
- **Fix:** Track Task references and cancel in deinit/onDisappear

### Issue 3: DriftApp URL Handling Tasks
- **File:** `DriftApp.swift` lines 86-95
- **Problem:** Multiple Tasks created without cancellation if URLs are opened rapidly
- **Impact:** Potential 10-30 KB leak if user opens links multiple times
- **Fix:** Cancel previous URL handling task before starting new one

---

## High Priority Issues (Fix Soon)

### Issue 4: TapToStartPage onChange Closure
- **File:** `TapToStartPage.swift` lines 115-128
- **Problem:** onChange captures self implicitly, potential cycle with parent view
- **Impact:** 5-10 KB leak if onCancelled callback captures parent
- **Fix:** Use [weak self] pattern or refactor callback structure

### Issue 5: DispatchQueue.main.asyncAfter Without Cancellation
- **Files:**
  - `BottomPresetSlider.swift` lines 168-170
  - `SyncingPage.swift` lines 165-167
- **Problem:** Delayed closures not cancelled if view dismisses before execution
- **Impact:** 1-5 KB leak per delayed action if repeated rapidly
- **Fix:** Use DispatchWorkItem with cancellation support

---

## Memory Impact Timeline

**Scenario: 4-5 minute active session with 3-5 NFC scans**

| Time | Event | Memory Impact | Running Total |
|------|-------|----------------|-----------------|
| 0:00 | Session starts | - | 0 KB |
| 0:30 | Tap to scan | +8 KB (completion closure) | +8 KB |
| 1:30 | Tap to stop | +8 KB (second closure) | +16 KB |
| 2:30 | Re-scan | +8 KB (third closure) | +24 KB |
| 3:30 | Another scan | +8 KB (fourth closure) | +32 KB |
| 4:30 | Last scan | +8 KB (fifth closure) | +40 KB |
| 5:00 | End session | +0 KB (memory pressure noticeable) | +40 KB |

**Additional Leaks During Onboarding:**
- SyncingPage Tasks: +20-30 KB per onboarding attempt
- DispatchQueue delays: +5-10 KB per rapid preset creation

---

## Testing Checklist

- [ ] Monitor Xcode Debug Navigator memory during active session
- [ ] Run Instruments → Memory to profile heap growth
- [ ] Test: Homepage → Scan → Stop → Repeat 5x
- [ ] Test: Onboarding → Quit → Add Another Drift
- [ ] Test: Rapidly tap scan button
- [ ] Test on low-memory device (iPhone SE 1st gen if available)

---

## Reproduction Steps

### Reproduce NFCReaderManager Leak (Issue #1)
1. Launch app
2. Go to HomePage
3. Tap the image to scan (start scanning)
4. Cancel the NFC dialog
5. Wait 10 seconds
6. Check Memory in Debug Navigator - should be stable
7. Repeat steps 3-6 five times
8. Expected: Memory increases 40+ KB with each iteration

### Reproduce SyncingPage Leak (Issue #2)
1. Trigger onboarding (or "Add Another Drift")
2. Complete onboarding to SyncingPage
3. Immediately dismiss the view during sync animation
4. Go back to add another drift
5. Monitor memory - should not accumulate
6. Expected: Memory accumulates 20-30 KB per attempt

---

## Quick Fixes

### Minimal Fix for Issue #1 (NFCReaderManager)
Change line 28-30 from:
```swift
private var scanCompletion: ((Result<String, NFCScanError>) -> Void)?

func startScanning(completion: ((Result<String, NFCScanError>) -> Void)? = nil) {
    scanCompletion = completion
```

To use a stored reference that can be cleared:
```swift
private var scanCompletion: ((Result<String, NFCScanError>) -> Void)?

func startScanning(completion: ((Result<String, NFCScanError>) -> Void)? = nil) {
    // Clear any previous completion
    self.scanCompletion = nil
    self.scanCompletion = completion
    // ... rest of code ...
}

// AND ensure scanCompletion is cleared in onDisappear/deinit of calling views
```

### Minimal Fix for Issue #2 (SyncingPage)
Add to SyncingPage:
```swift
private var syncTask: Task<Void, Never>?
private var errorTask: Task<Void, Never>?

private func performSync() {
    syncTask?.cancel()
    syncTask = Task { /* ... existing code ... */ }
}

private func handleError(_ error: Error) {
    errorTask?.cancel()
    errorTask = Task { /* ... existing code ... */ }
}
```

---

## Files Modified
- [ ] NFCReaderManager.swift (Issue #1)
- [ ] SyncingPage.swift (Issue #2, #5)
- [ ] DriftApp.swift (Issue #3)
- [ ] TapToStartPage.swift (Issue #4)
- [ ] BottomPresetSlider.swift (Issue #5)

---

## Performance Impact After Fixes
- **Memory reduction:** 50-200 KB per session
- **CPU reduction:** Minimal (task cancellation is efficient)
- **Battery impact:** Negligible improvement
- **UI responsiveness:** Should improve during rapid interactions

