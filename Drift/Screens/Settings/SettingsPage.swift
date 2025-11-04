//
//  SettingsPage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct SettingsPage: View {
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            VStack {
                Text("Settings")
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignTokens.Padding.large)

                Spacer()
            }
        }
    }
}

#Preview {
    SettingsPage()
}
