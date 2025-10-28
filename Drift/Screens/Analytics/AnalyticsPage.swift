//
//  AnalyticsPage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct AnalyticsPage: View {
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            Text("Analytics")
                .heading1()
                .foregroundColor(DesignTokens.Colors.textPrimary)
        }
    }
}

#Preview {
    AnalyticsPage()
}
