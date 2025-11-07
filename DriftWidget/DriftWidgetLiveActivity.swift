//
//  DriftWidgetLiveActivity.swift
//  DriftWidget
//
//  Created by William Forkes on 07/11/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DriftWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Empty for now - extensible for future features like:
        // - preset name/emoji
        // - progress percentage
        // - completion status
    }

    // Fixed properties for the focus session
    var sessionStartDate: Date
}

struct DriftWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DriftWidgetAttributes.self) { context in
            // Lock screen/banner UI
            HStack(spacing: DesignTokens.Spacing.xLarge) {
                // Live countdown timer
                Text(context.attributes.sessionStartDate, style: .timer)
                    .heading2()
                    .monospacedDigit()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Spacer()

                Image("above_small")
                    .resizable()
                    .scaledToFit()
            }
            .padding(DesignTokens.Padding.large)
            .activityBackgroundTint(DesignTokens.Colors.background)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Image("above_small")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.sessionStartDate, style: .timer)
                        .heading2()
                        .monospacedDigit()
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Focus Session Active")
                        .bodySmall()
                        .subtextColor()
                }
            } compactLeading: {
                Image("above_small")
                    .resizable()
                    .scaledToFill()
            } compactTrailing: {
                Text(context.attributes.sessionStartDate, style: .timer)
                    .bodySmall()
                    .monospacedDigit()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
            } minimal: {
                Image("above_small")
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

extension DriftWidgetAttributes {
    fileprivate static var preview: DriftWidgetAttributes {
        DriftWidgetAttributes(sessionStartDate: Date())
    }
}

extension DriftWidgetAttributes.ContentState {
    fileprivate static var active: DriftWidgetAttributes.ContentState {
        DriftWidgetAttributes.ContentState()
    }
}

#Preview("Notification", as: .content, using: DriftWidgetAttributes.preview) {
   DriftWidgetLiveActivity()
} contentStates: {
    DriftWidgetAttributes.ContentState.active
}
