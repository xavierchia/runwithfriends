import WidgetKit
import SwiftUI
import HealthKit

class HealthStore {
    static let shared = HealthStore()
    let healthStore = HKHealthStore()
    private let defaults = UserDefaults.standard
    
    private var lastKnownSteps: Int {
        get {
            return defaults.integer(forKey: "lastKnownSteps")
        }
        set {
            defaults.set(newValue, forKey: "lastKnownSteps")
            print("Saved lastKnownSteps to UserDefaults: \(newValue)")
        }
    }
    
    private var lastError: String {
        get {
            return defaults.string(forKey: "lastError") ?? "none"
        }
        set {
            defaults.set(newValue, forKey: "lastError")
        }
    }
    
    private var updateCount: Int {
        get {
            return defaults.integer(forKey: "updateCount")
        }
        set {
            defaults.set(newValue, forKey: "updateCount")
        }
    }
    
    private var lastUpdateTime: Date {
        get {
            return defaults.object(forKey: "lastUpdateTime") as? Date ?? Date()
        }
        set {
            defaults.set(newValue, forKey: "lastUpdateTime")
        }
    }
    
    func getLastKnownSteps() -> Int {
        return lastKnownSteps
    }
    
    func getDebugInfo() -> (error: String, updateCount: Int, lastUpdate: Date) {
        return (lastError, updateCount, lastUpdateTime)
    }
    
    func resetDailyStats() {
        if !Calendar.current.isDate(lastUpdateTime, inSameDayAs: Date()) {
            print("New day detected, resetting stats")
            updateCount = 0
            lastKnownSteps = 0
            lastError = "none"
        }
    }
    
    func fetchSteps(for date: Date) async throws -> Int {
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
                self.updateCount += 1
                self.lastUpdateTime = Date()
                
                if let error = error {
                    print("HealthKit query error: \(error)")
                    self.lastError = "query"
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let steps = result?.sumQuantity()?.doubleValue(for: .count()) else {
                    print("No step data available")
                    self.lastError = "nodata"
                    continuation.resume(throwing: NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "No step data available"]))
                    return
                }
                
                self.lastKnownSteps = Int(steps)
                self.lastError = "none"
                print("Successfully fetched steps: \(steps)")
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
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
        let debugInfo = HealthStore.shared.getDebugInfo()
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            steps: HealthStore.shared.getLastKnownSteps(),
            lastError: debugInfo.error,
            updateCount: debugInfo.updateCount,
            lastUpdateTime: debugInfo.lastUpdate,
            family: context.family
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let debugInfo = HealthStore.shared.getDebugInfo()
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: HealthStore.shared.getLastKnownSteps(),
            lastError: debugInfo.error,
            updateCount: debugInfo.updateCount,
            lastUpdateTime: debugInfo.lastUpdate,
            family: context.family
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        HealthStore.shared.resetDailyStats()
        
        do {
            let steps = try await HealthStore.shared.fetchSteps(for: currentDate)
            let debugInfo = HealthStore.shared.getDebugInfo()
            
            let entry = SimpleEntry(
                date: currentDate,
                configuration: configuration,
                steps: steps,
                lastError: debugInfo.error,
                updateCount: debugInfo.updateCount,
                lastUpdateTime: debugInfo.lastUpdate,
                family: context.family
            )
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
            return Timeline(entries: [entry], policy: .after(nextUpdate))
            
        } catch {
            print("Error fetching health data: \(error)")
            print("Using last known steps: \(HealthStore.shared.getLastKnownSteps())")
            let debugInfo = HealthStore.shared.getDebugInfo()
            return Timeline(entries: [
                SimpleEntry(
                    date: currentDate,
                    configuration: configuration,
                    steps: HealthStore.shared.getLastKnownSteps(),
                    lastError: debugInfo.error,
                    updateCount: debugInfo.updateCount,
                    lastUpdateTime: debugInfo.lastUpdate,
                    family: context.family
                )
            ], policy: .after(Date().addingTimeInterval(60)))
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
