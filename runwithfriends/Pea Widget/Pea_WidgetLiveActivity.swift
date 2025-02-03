//
//  Pea_WidgetLiveActivity.swift
//  Pea Widget
//
//  Created by Xavier Chia PY on 3/2/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Pea_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Pea_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Pea_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Pea_WidgetAttributes {
    fileprivate static var preview: Pea_WidgetAttributes {
        Pea_WidgetAttributes(name: "World")
    }
}

extension Pea_WidgetAttributes.ContentState {
    fileprivate static var smiley: Pea_WidgetAttributes.ContentState {
        Pea_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Pea_WidgetAttributes.ContentState {
         Pea_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Pea_WidgetAttributes.preview) {
   Pea_WidgetLiveActivity()
} contentStates: {
    Pea_WidgetAttributes.ContentState.smiley
    Pea_WidgetAttributes.ContentState.starEyes
}
