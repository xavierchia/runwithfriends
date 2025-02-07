import WidgetKit
import SwiftUI
import HealthKit

extension String: @retroactive Error {}

class HealthStore {
    static let myHealthStore = HKHealthStore()
    static let defaults = UserDefaults.standard
    static let sharedDefaults = UserDefaults(suiteName: "group.com.wholesomeapps.runwithfriends")

    static var lastKnownSteps: Int {
        get {
            return sharedDefaults?.integer(forKey: "userDaySteps") ?? 0
        }
        set {
            sharedDefaults?.set(newValue, forKey: "userDaySteps")
            print("Saved userDaySteps to UserDefaults: \(newValue)")
        }
    }
    
    static var lastError: String {
        get {
            return defaults.string(forKey: "lastError") ?? "none"
        }
        set {
            defaults.set(newValue, forKey: "lastError")
        }
    }
    
    static var updateCount: Int {
        get {
            return defaults.integer(forKey: "updateCount")
        }
        set {
            defaults.set(newValue, forKey: "updateCount")
        }
    }
    
    static var lastUpdateTime: Date {
        get {
            return defaults.object(forKey: "lastUpdateTime") as? Date ?? Date()
        }
        set {
            defaults.set(newValue, forKey: "lastUpdateTime")
        }
    }

    static func getDebugInfo() -> (error: String, updateCount: Int, lastUpdate: Date) {
        return (lastError, updateCount, lastUpdateTime)
    }
    
    static func resetDailyStats() {
        if !Calendar.current.isDate(lastUpdateTime, inSameDayAs: Date()) {
            print("New day detected, resetting stats")
            updateCount = 0
            lastKnownSteps = 0
            lastError = "reset"
        }
    }
    
    static func fetchSteps(for date: Date) async throws -> Int {
        print("Fetching steps for date: \(date)")
        let stepType = HKQuantityType(.stepCount)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: date),
            end: date
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: "query")
                    return
                }
                
                guard let steps = result?.sumQuantity()?.doubleValue(for: .count()) else {
                    print("No step data available")
                    continuation.resume(throwing: "nodata")
                    return
                }
                print("Successfully fetched steps: \(steps)")
                continuation.resume(returning: Int(steps))
            }
            
            HealthStore.myHealthStore.execute(query)
        }
    }
}

// test
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let steps: Int
    let lastError: String
    let updateCount: Int
    let lastUpdateTime: Date
    let family: WidgetFamily
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let debugInfo = HealthStore.getDebugInfo()
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            steps: HealthStore.lastKnownSteps,
            lastError: debugInfo.error,
            updateCount: debugInfo.updateCount,
            lastUpdateTime: debugInfo.lastUpdate,
            family: context.family
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let debugInfo = HealthStore.getDebugInfo()
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: HealthStore.lastKnownSteps,
            lastError: debugInfo.error,
            updateCount: debugInfo.updateCount,
            lastUpdateTime: debugInfo.lastUpdate,
            family: context.family
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        HealthStore.resetDailyStats()
        
        do {
            HealthStore.updateCount += 1
            HealthStore.lastUpdateTime = Date()
            let steps = try await HealthStore.fetchSteps(for: currentDate)
            let debugInfo = HealthStore.getDebugInfo()
            
            let entry = SimpleEntry(
                date: currentDate,
                configuration: configuration,
                steps: steps,
                lastError: debugInfo.error,
                updateCount: debugInfo.updateCount,
                lastUpdateTime: debugInfo.lastUpdate,
                family: context.family
            )
            
            HealthStore.lastKnownSteps = Int(steps) > HealthStore.lastKnownSteps ? Int(steps) : HealthStore.lastKnownSteps
            HealthStore.lastError = "none"
            // On success, update after 10 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            return Timeline(entries: [entry], policy: .after(nextUpdate))
            
        } catch {
            HealthStore.lastError = "\(error)"
            print("Error fetching health data: \(error)")
            print("Using last known steps: \(HealthStore.lastKnownSteps)")
            let debugInfo = HealthStore.getDebugInfo()
            
            let entry = SimpleEntry(
                date: currentDate,
                configuration: configuration,
                steps: HealthStore.lastKnownSteps,
                lastError: debugInfo.error,
                updateCount: debugInfo.updateCount,
                lastUpdateTime: debugInfo.lastUpdate,
                family: context.family
            )
            
            // On failure, retry after 2 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 2, to: currentDate)!
            return Timeline(entries: [entry], policy: .after(nextUpdate))
        }
    }
}

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

#Preview(as: .systemSmall) {
    Pea_Widget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .smiley,
        steps: 3000,
        lastError: "none",
        updateCount: 5,
        lastUpdateTime: Date(),
        family: .systemSmall
    )
    SimpleEntry(
        date: .now,
        configuration: .starEyes,
        steps: 5000,
        lastError: "query",
        updateCount: 6,
        lastUpdateTime: Date(),
        family: .systemSmall
    )
}

#Preview(as: .accessoryCircular) {
    Pea_Widget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .smiley,
        steps: 3000,
        lastError: "none",
        updateCount: 5,
        lastUpdateTime: Date(),
        family: .accessoryCircular
    )
}
