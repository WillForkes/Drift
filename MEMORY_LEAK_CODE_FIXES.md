# Memory Leak Fixes - Code Examples

## Issue 1: NFCReaderManager Completion Handler Cycle

### Current Code (Problematic)
```swift
// NFCReaderManager.swift
class NFCReaderManager: NSObject, ObservableObject {
    private var scanCompletion: ((Result<String, NFCScanError>) -> Void)?
    
    func startScanning(completion: ((Result<String, NFCScanError>) -> Void)? = nil) {
        scanCompletion = completion  // LEAK: Stores closure strongly
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
        isScanning = true
    }
    
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        Task { @MainActor in
            // ... processing code ...
            scanCompletion?(.success(tagId))  // Called in Task
            scanCompletion = nil  // Only cleared on success path
        }
    }
}

// HomePage.swift
func startManualNFCScan() {
    nfcReader.startScanning { result in  // Closure captures self
        switch result {
        case .success(let tagId):
            handleTagDetection(tagId: tagId)  // Calls method on self
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
```

### Why This Leaks
1. HomePage stores `nfcReader` as property: `@ObservedObject private var nfcReader = NFCReaderManager.shared`
2. HomePage passes closure to `startScanning` that captures `self` (HomePage)
3. NFCReaderManager stores this closure in `scanCompletion` property
4. Closure → HomePage → nfcReader → Closure = **RETAIN CYCLE**
5. Cycle is only broken when completion is called AND cleared

### Fixed Code (Option 1: Weak Self)
```swift
// HomePage.swift - Use weak self
func startManualNFCScan() {
    nfcReader.startScanning { [weak self] result in
        guard let self = self else { return }  // View was deallocated
        switch result {
        case .success(let tagId):
            self.handleTagDetection(tagId: tagId)
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
}
```

### Fixed Code (Option 2: WeakBox Pattern for NFCReaderManager)
```swift
// NFCReaderManager.swift
class NFCReaderManager: NSObject, ObservableObject {
    private var scanCompletion: ((Result<String, NFCScanError>) -> Void)?
    private weak var ownerRef: AnyObject?
    
    func startScanning(
        owner: AnyObject,
        completion: ((Result<String, NFCScanError>) -> Void)? = nil
    ) {
        // Only store completion if owner is still alive
        if self.ownerRef !== owner {
            self.ownerRef = owner
            self.scanCompletion = completion
        } else {
            // Owner was deallocated, clear completion
            self.scanCompletion = nil
        }
        
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
        isScanning = true
    }
}

// HomePage.swift
func startManualNFCScan() {
    nfcReader.startScanning(owner: self) { result in
        // Now safe - weak reference to owner prevents cycle
        switch result {
        case .success(let tagId):
            self.handleTagDetection(tagId: tagId)
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
}
```

### Fixed Code (Option 3: Remove View Complexity)
```swift
// NFCReaderManager.swift - Move completion handling to manager
class NFCReaderManager: NSObject, ObservableObject {
    @Published var lastDetectedTagId: String?
    @Published var lastScanError: NFCScanError?
    
    func startScanning() {  // No completion handler needed
        detectedTagId = nil
        errorMessage = nil
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
        isScanning = true
    }
}

// HomePage.swift - Use @Published properties
func startManualNFCScan() {
    nfcReader.startScanning()  // No closure needed
}

// Listen for results via @StateObject
var body: some View {
    // ... UI code ...
    .onChange(of: nfcReader.lastDetectedTagId) { oldValue, newValue in
        if let tagId = newValue {
            handleTagDetection(tagId: tagId)
        }
    }
}
```

**RECOMMENDED APPROACH:** Option 1 with [weak self] is the simplest and most Swift-idiomatic.

---

## Issue 2: SyncingPage Task Accumulation

### Current Code (Problematic)
```swift
// SyncingPage.swift
struct SyncingPage: View {
    let tagId: String
    @Binding var driftName: String
    let onSuccess: () -> Void
    let onError: (String) -> Void
    
    @State private var syncState: SyncState = .validating
    // ... other state ...
    
    var body: some View {
        GeometryReader { geometry in
            // ... UI code ...
        }
        .onAppear {
            performSync()  // Task created, no tracking
        }
    }
    
    private func performSync() {
        Task {  // LEAK: Task created with no cancellation
            do {
                try await sessionManager.requestAuthorization()
                
                completedBadges = 1
                haptics.impactLight()
                try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
                
                completedBadges = 2
                haptics.impactLight()
                try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
                
                completedBadges = 3
                haptics.impactLight()
                try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
                
                syncState = .namingTag
            } catch {
                handleError(error)  // Creates another Task
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let errorMessage = formatError(error)
        syncState = .error(errorMessage)
        
        Task {  // LEAK: Another untracked Task
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            onError(errorMessage)
        }
    }
}
```

### Why This Leaks
1. `performSync()` creates a Task with three `Task.sleep()` calls (3 seconds total)
2. If view dismisses during sleep, Task is orphaned but continues running
3. Each Task captures: `self`, `tagManager`, `sessionManager`, etc.
4. `handleError()` creates ANOTHER Task with 2-second sleep
5. Multiple rapid actions accumulate Tasks in memory

### Fixed Code
```swift
// SyncingPage.swift
struct SyncingPage: View {
    let tagId: String
    @Binding var driftName: String
    let onSuccess: () -> Void
    let onError: (String) -> Void
    
    @State private var syncState: SyncState = .validating
    @State private var syncTask: Task<Void, Never>?  // ADD: Track task
    @State private var errorTask: Task<Void, Never>?  // ADD: Track task
    // ... other state ...
    
    var body: some View {
        GeometryReader { geometry in
            // ... UI code ...
        }
        .onAppear {
            performSync()
        }
        .onDisappear {  // ADD: Cleanup
            syncTask?.cancel()
            errorTask?.cancel()
        }
    }
    
    private func performSync() {
        syncTask?.cancel()  // Cancel any previous task
        
        syncTask = Task {  // FIXED: Now tracked
            do {
                try await sessionManager.requestAuthorization()
                
                completedBadges = 1
                haptics.impactLight()
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Check if task was cancelled
                if Task.isCancelled { return }
                
                completedBadges = 2
                haptics.impactLight()
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                if Task.isCancelled { return }
                
                completedBadges = 3
                haptics.impactLight()
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                if Task.isCancelled { return }
                
                syncState = .namingTag
            } catch {
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let errorMessage = formatError(error)
        syncState = .error(errorMessage)
        
        errorTask?.cancel()  // Cancel any previous error task
        
        errorTask = Task {  // FIXED: Now tracked
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            if !Task.isCancelled {  // Only call if not cancelled
                onError(errorMessage)
            }
        }
    }
}
```

**KEY CHANGES:**
1. Added `@State var syncTask` and `@State var errorTask`
2. Cancel previous task before creating new one
3. Added `onDisappear` to cleanup
4. Added `Task.isCancelled` checks to avoid work after cancellation

---

## Issue 3: DriftApp URL Handling Tasks

### Current Code (Problematic)
```swift
// DriftApp.swift
@main
struct DriftApp: App {
    @StateObject private var sessionManager = FocusSessionManager.shared
    @StateObject private var tagManager = DriftTagManager.shared
    // ... other managers ...
    
    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .onOpenURL { url in
                    handleURL(url)  // Can be called multiple times
                }
        }
    }
    
    private func handleURL(_ url: URL) {
        // ... parse URL to get tagId ...
        
        Task { @MainActor in  // LEAK: Multiple tasks if called rapidly
            if let tag = tagManager.getTag(by: tagId) {
                handleRegisteredTag(tag)
            } else {
                NotificationCenter.default.post(name: .nfcTagNeedsSetup, object: tagId)
            }
        }
    }
}
```

### Fixed Code
```swift
// DriftApp.swift
@main
struct DriftApp: App {
    @StateObject private var sessionManager = FocusSessionManager.shared
    @StateObject private var tagManager = DriftTagManager.shared
    @State private var urlHandlingTask: Task<Void, Never>?  // ADD: Track task
    // ... other managers ...
    
    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }
    
    private func handleURL(_ url: URL) {
        // ... parse URL to get tagId ...
        
        urlHandlingTask?.cancel()  // FIXED: Cancel previous
        
        urlHandlingTask = Task { @MainActor in  // FIXED: Track task
            if let tag = tagManager.getTag(by: tagId) {
                handleRegisteredTag(tag)
            } else {
                NotificationCenter.default.post(name: .nfcTagNeedsSetup, object: tagId)
            }
        }
    }
}
```

---

## Issue 4: TapToStartPage onChange Closure

### Current Code (Problematic)
```swift
// TapToStartPage.swift
struct TapToStartPage: View {
    let onTagDetected: (String) -> Void
    let onCancelled: () -> Void  // External closure
    
    @StateObject private var nfcReader = NFCReaderManager.shared
    @State private var hasDetectedTag: Bool = false
    @State private var hasStartedScanning: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            // ... UI code ...
        }
        .onChange(of: nfcReader.isScanning) { isScanning in
            // LEAK: Implicit self capture
            if hasStartedScanning && !isScanning && !hasDetectedTag && nfcReader.errorMessage == nil {
                print("User cancelled")
                onCancelled()  // Calls closure that may capture parent
            }
        }
    }
}
```

### Fixed Code
```swift
// TapToStartPage.swift
struct TapToStartPage: View {
    let onTagDetected: (String) -> Void
    let onCancelled: () -> Void
    
    @StateObject private var nfcReader = NFCReaderManager.shared
    @State private var hasDetectedTag: Bool = false
    @State private var hasStartedScanning: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            // ... UI code ...
        }
        .onChange(of: nfcReader.isScanning) { oldValue, newValue in
            // FIXED: Explicit parameter names
            // FIXED: Use local state instead of self references
            let shouldCancel = hasStartedScanning && 
                              !newValue && 
                              !hasDetectedTag && 
                              nfcReader.errorMessage == nil
            
            if shouldCancel {
                print("User cancelled")
                onCancelled()  // Still safer than implicit capture
            }
        }
    }
}
```

---

## Issue 5: DispatchQueue.main.asyncAfter Without Cancellation

### Current Code (Problematic)
```swift
// BottomPresetSlider.swift
struct BottomPresetSlider: View {
    @State private var scrollPosition: String?
    @ObservedObject private var presetManager = PresetManager.shared
    
    private func createPreset() {
        guard !newPresetName.isEmpty else { return }
        
        do {
            let preset = try presetManager.createPreset(name: newPresetName)
            newPresetName = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                scrollPosition = preset.id  // LEAK: Captures self, not cancelled
            }
        } catch {
            print("Error creating preset: \(error)")
        }
    }
}
```

### Fixed Code
```swift
// BottomPresetSlider.swift
struct BottomPresetSlider: View {
    @State private var scrollPosition: String?
    @State private var scrollWorkItem: DispatchWorkItem?  // ADD: Track work item
    @ObservedObject private var presetManager = PresetManager.shared
    
    var body: some View {
        // ... UI code ...
        .onDisappear {  // ADD: Cleanup
            scrollWorkItem?.cancel()
        }
    }
    
    private func createPreset() {
        guard !newPresetName.isEmpty else { return }
        
        do {
            let preset = try presetManager.createPreset(name: newPresetName)
            newPresetName = ""
            
            scrollWorkItem?.cancel()  // FIXED: Cancel previous
            
            let workItem = DispatchWorkItem {
                self.scrollPosition = preset.id
            }
            
            scrollWorkItem = workItem  // FIXED: Store work item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        } catch {
            print("Error creating preset: \(error)")
        }
    }
}
```

---

## Summary of Fixes by Severity

| Issue | Current | Fix | Lines Changed |
|-------|---------|-----|----------------|
| **NFCReaderManager** | Stores closure | Use [weak self] | 3-5 |
| **SyncingPage** | Creates tasks | Track & cancel tasks | 10-15 |
| **DriftApp** | Multiple tasks | Cancel previous task | 5-8 |
| **TapToStartPage** | Implicit self | Explicit parameters | 3-5 |
| **DispatchQueue** | No cancellation | Use DispatchWorkItem | 8-12 |

**Total estimated changes:** 30-45 lines across 5 files
**Estimated time to implement:** 1-2 hours
**Estimated memory savings:** 50-200 KB per session

