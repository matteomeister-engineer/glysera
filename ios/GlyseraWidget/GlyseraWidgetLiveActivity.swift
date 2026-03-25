//
//  GlyseraWidgetLiveActivity.swift
//  GlyseraWidget
//
//  Created by Mattéo Meister on 23.03.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GlyseraWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GlyseraWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GlyseraWidgetAttributes.self) { context in
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

extension GlyseraWidgetAttributes {
    fileprivate static var preview: GlyseraWidgetAttributes {
        GlyseraWidgetAttributes(name: "World")
    }
}

extension GlyseraWidgetAttributes.ContentState {
    fileprivate static var smiley: GlyseraWidgetAttributes.ContentState {
        GlyseraWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GlyseraWidgetAttributes.ContentState {
         GlyseraWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GlyseraWidgetAttributes.preview) {
   GlyseraWidgetLiveActivity()
} contentStates: {
    GlyseraWidgetAttributes.ContentState.smiley
    GlyseraWidgetAttributes.ContentState.starEyes
}
