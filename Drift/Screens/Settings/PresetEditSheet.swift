//
//  PresetEditSheet.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct PresetEditSheet: View {
    @Binding var isPresented: Bool
    @State private var preset: FocusPreset
    @State private var selectedApps: Set<String> = []
    @State private var includeMode: Bool = true // true = include, false = exclude
    
    // Mock data for app categories
    @State private var appCategories: [AppCategory] = [
        AppCategory(name: "Social Media", apps: [
            MockApp(id: "instagram", name: "Instagram", iconName: "camera.fill"),
            MockApp(id: "twitter", name: "Twitter", iconName: "message.fill"),
            MockApp(id: "facebook", name: "Facebook", iconName: "person.3.fill"),
            MockApp(id: "tiktok", name: "TikTok", iconName: "play.fill"),
            MockApp(id: "snapchat", name: "Snapchat", iconName: "camera.viewfinder"),
            MockApp(id: "linkedin", name: "LinkedIn", iconName: "briefcase.fill"),
            MockApp(id: "reddit", name: "Reddit", iconName: "bubble.left.and.bubble.right.fill")
        ]),
        AppCategory(name: "Utility", apps: [
            MockApp(id: "calculator", name: "Calculator", iconName: "plus.forwardslash.minus"),
            MockApp(id: "notes", name: "Notes", iconName: "note.text"),
            MockApp(id: "calendar", name: "Calendar", iconName: "calendar"),
            MockApp(id: "weather", name: "Weather", iconName: "cloud.sun.fill"),
            MockApp(id: "clock", name: "Clock", iconName: "clock.fill"),
            MockApp(id: "settings", name: "Settings", iconName: "gear"),
            MockApp(id: "files", name: "Files", iconName: "folder.fill")
        ]),
        AppCategory(name: "Entertainment", apps: [
            MockApp(id: "netflix", name: "Netflix", iconName: "tv.fill"),
            MockApp(id: "spotify", name: "Spotify", iconName: "music.note"),
            MockApp(id: "youtube", name: "YouTube", iconName: "play.rectangle.fill"),
            MockApp(id: "twitch", name: "Twitch", iconName: "gamecontroller.fill"),
            MockApp(id: "disney", name: "Disney+", iconName: "star.fill"),
            MockApp(id: "hulu", name: "Hulu", iconName: "tv.circle.fill"),
            MockApp(id: "amazon", name: "Prime Video", iconName: "play.tv.fill")
        ]),
        AppCategory(name: "Games", apps: [
            MockApp(id: "clash", name: "Clash Royale", iconName: "gamecontroller.fill"),
            MockApp(id: "candy", name: "Candy Crush", iconName: "diamond.fill"),
            MockApp(id: "pokemon", name: "Pokémon GO", iconName: "location.fill"),
            MockApp(id: "minecraft", name: "Minecraft", iconName: "cube.fill"),
            MockApp(id: "fortnite", name: "Fortnite", iconName: "target"),
            MockApp(id: "among", name: "Among Us", iconName: "person.fill"),
            MockApp(id: "roblox", name: "Roblox", iconName: "square.stack.3d.up.fill")
        ])
    ]
    
    init(preset: FocusPreset, isPresented: Binding<Bool>) {
        self._preset = State(initialValue: preset)
        self._isPresented = isPresented
    }
    
    var selectedCount: Int {
        return selectedApps.count
    }
    
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.black)
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xxxLarge) {
                        // Header Section
                        VStack(spacing: DesignTokens.Spacing.xLarge) {
                            HStack {
                                Text("Editing '\(preset.name)'")
                                    .heading1()
                                    .foregroundColor(DesignTokens.Colors.textPrimary)
                                
                                Spacer()
                                
                                DriftButton(title: "Save", style: .pill) {
                                    savePreset()
                                }
                            }
                            .padding(.horizontal, DesignTokens.Padding.large)
                            
                            // Device Assignment Card
                            DeviceAssignmentCard(selectedCount: selectedCount)
                                .padding(.horizontal, DesignTokens.Padding.large)
                        }
                        
                        // Select Apps Section
                        VStack(spacing: DesignTokens.Spacing.xLarge) {
                            // Section Header with Include/Exclude Toggle
                            VStack(spacing: DesignTokens.Spacing.xLarge) {
                                HStack {
                                    Text("Select Apps")
                                        .heading1()
                                        .foregroundColor(DesignTokens.Colors.textPrimary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, DesignTokens.Padding.large)
                                
                                // Include/Exclude Toggle
                                HStack(spacing: 0) {
                                    ToggleButton(
                                        title: "Include",
                                        isSelected: includeMode,
                                        isLeading: true
                                    ) {
                                        includeMode = true
                                    }
                                    
                                    ToggleButton(
                                        title: "Exclude",
                                        isSelected: !includeMode,
                                        isLeading: false
                                    ) {
                                        includeMode = false
                                    }
                                }
                                .padding(.horizontal, DesignTokens.Padding.large)
                            }
                            
                            // App Categories
                            ForEach(appCategories, id: \.name) { category in
                                AppCategorySection(
                                    category: category,
                                    selectedApps: $selectedApps
                                )
                                .padding(.horizontal, DesignTokens.Padding.large)
                            }
                            
                            // Bottom spacing
                            Spacer()
                                .frame(height: DesignTokens.Spacing.xxxLarge)
                        }
                    }
                    .padding(.top, DesignTokens.Spacing.xLarge)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
    
    private func savePreset() {
        // TODO: Save preset logic
        print("Saving preset: \(preset.name) with \(selectedApps.count) selected apps")
        isPresented = false
    }
}

// MARK: - Supporting Views

struct DeviceAssignmentCard: View {
    let selectedCount: Int
    
    var body: some View {
        HStack {
            Text("Living Room")
                .body()
                .foregroundColor(DesignTokens.Colors.textPrimary)
            
            Spacer()
            
            Text("\(selectedCount) Selected Apps")
                .bodySmall()
                .extraSubtextColor()
        }
        .padding(DesignTokens.Padding.large)
        .background(DesignTokens.Colors.whiteText)
        .cornerRadius(DesignTokens.Radii.radiusStandard)
        .shadow(
            color: DesignTokens.Shadow.color,
            radius: DesignTokens.Shadow.radius,
            x: DesignTokens.Shadow.x,
            y: DesignTokens.Shadow.y
        )
    }
}

struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let isLeading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .bodySmall()
                .foregroundColor(isSelected ? DesignTokens.Colors.whiteText : DesignTokens.Colors.textPrimary)
                .padding(.horizontal, DesignTokens.Padding.large)
                .padding(.vertical, DesignTokens.Padding.medium)
                .background(isSelected ? DesignTokens.Colors.primary : DesignTokens.Colors.accent)
                .cornerRadius(20, corners: isLeading ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight])
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AppCategorySection: View {
    let category: AppCategory
    @Binding var selectedApps: Set<String>
    
    private var isAllSelected: Bool {
        category.apps.allSatisfy { selectedApps.contains($0.id) }
    }
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xLarge) {
            // Category Header
            HStack {
                Text(category.name)
                    .body()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
                
                Button(action: toggleAllApps) {
                    Text(isAllSelected ? "Deselect All" : "Select All")
                        .bodySmall()
                        .subtextColor()
                }
            }
            
            // App Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DesignTokens.Spacing.medium), count: 7), spacing: DesignTokens.Spacing.medium) {
                ForEach(category.apps, id: \.id) { app in
                    AppIconView(
                        app: app,
                        isSelected: selectedApps.contains(app.id)
                    ) {
                        toggleApp(app)
                    }
                }
            }
        }
        .padding(DesignTokens.Padding.large)
        .background(DesignTokens.Colors.whiteText)
        .cornerRadius(DesignTokens.Radii.radiusStandard)
        .shadow(
            color: DesignTokens.Shadow.color,
            radius: DesignTokens.Shadow.radius,
            x: DesignTokens.Shadow.x,
            y: DesignTokens.Shadow.y
        )
    }
    
    private func toggleApp(_ app: MockApp) {
        if selectedApps.contains(app.id) {
            selectedApps.remove(app.id)
        } else {
            selectedApps.insert(app.id)
        }
    }
    
    private func toggleAllApps() {
        if isAllSelected {
            // Deselect all apps in this category
            for app in category.apps {
                selectedApps.remove(app.id)
            }
        } else {
            // Select all apps in this category
            for app in category.apps {
                selectedApps.insert(app.id)
            }
        }
    }
}

struct AppIconView: View {
    let app: MockApp
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // App icon background
                RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusSmall)
                    .fill(isSelected ? DesignTokens.Colors.primary.opacity(0.2) : DesignTokens.Colors.background)
                    .frame(width: 44, height: 44)
                
                // App icon
                Image(systemName: app.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? DesignTokens.Colors.primary : DesignTokens.Colors.textPrimary.opacity(0.6))
                
                // Selection indicator
                if isSelected {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(DesignTokens.Colors.whiteText)
                                .padding(2)
                                .background(DesignTokens.Colors.primary)
                                .clipShape(Circle())
                        }
                    }
                    .frame(width: 44, height: 44)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Models

struct MockApp {
    let id: String
    let name: String
    let iconName: String
}

struct AppCategory {
    let name: String
    let apps: [MockApp]
}

// MARK: - Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    PresetEditSheet(
        preset: FocusPreset.work,
        isPresented: .constant(true)
    )
}