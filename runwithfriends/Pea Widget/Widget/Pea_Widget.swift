import WidgetKit
import SwiftUI
import CoreMotion
import HealthKit

struct Pea_WidgetEntryView : View {
    var entry: Provider.Entry
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(entry.steps) steps")
                .font(.headline)
            Text("Err: \(entry.lastError)")
                .font(.caption2)
            Text("Last: \(entry.lastUpdateTime, formatter: dateFormatter)")
                .font(.caption2)
            Text("Updates: \(entry.updateCount)")
                .font(.caption2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .foregroundColor(.black)
    }
}

struct LockScreenWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        Text("\(entry.steps)")
        Text("steps")
    }
}

struct Pea_Widget: Widget {
    let kind: String = "Pea_Widget"
    let creamColor = Color(red: 0.96, green: 0.95, blue: 0.90)

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 16.0, *) {
                switch entry.family {
                case .accessoryCircular, .accessoryRectangular, .accessoryInline:
                    LockScreenWidgetView(entry: entry)
                        .containerBackground(Color.black, for: .widget)
                default:
                    Pea_WidgetEntryView(entry: entry)
                        .containerBackground(creamColor, for: .widget)
                }
            } else {
                Pea_WidgetEntryView(entry: entry)
                    .containerBackground(creamColor, for: .widget)
            }
        }
        .configurationDisplayName("Steps Widget")
        .description("Track your daily steps")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}
