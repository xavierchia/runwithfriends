import WidgetKit
import SwiftUI
import CoreMotion
import HealthKit

struct Pea_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header with steps count
            Text("TODAY'S STEPS")
                .font(Font.quicksandBold(size: 15))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
            
            if entry.friends.isEmpty {
                Text("\(entry.steps)")
                    .font(.quicksandBold(size: 15))
            } else {
                Divider()
                
                // Friends list
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.friends, id: \.user_id) { friend in
                        HStack {
                            Text("\(friend.ranking) \(friend.username)")
                                .font(Font.quicksandBold(size: 15))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(friend.steps)")
                                .font(Font.quicksandMedium(size: 15))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
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
                        .environment(\.sizeCategory, .medium)  // This disables Dynamic Type scaling
                }
            } else {
                Pea_WidgetEntryView(entry: entry)
                    .containerBackground(creamColor, for: .widget)
                    .environment(\.sizeCategory, .medium)  // This disables Dynamic Type scaling
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

extension Font {
    public static func quicksandBold(size: CGFloat) -> Font {
        Font.custom("Quicksand-Bold", size: size)
    }
    
    public static func quicksandSemiBold(size: CGFloat) -> Font {
        Font.custom("Quicksand-SemiBold", size: size)
    }
    
    public static func quicksandMedium(size: CGFloat) -> Font {
        Font.custom("Quicksand-Medium", size: size)
    }
    
    public static func quicksand(size: CGFloat) -> Font {
        Font.custom("Quicksand-Regular", size: size)
    }
    
    public static func quicksandLight(size: CGFloat) -> Font {
        Font.custom("Quicksand-Light", size: size)
    }
}
