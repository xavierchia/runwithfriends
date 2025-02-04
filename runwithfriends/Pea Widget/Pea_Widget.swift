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
    
    func resetUpdateCount() {
        if !Calendar.current.isDate(lastUpdateTime, inSameDayAs: Date()) {
            updateCount = 0
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let steps: Int
    let lastError: String
    let updateCount: Int
    let lastUpdateTime: Date
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
            lastUpdateTime: debugInfo.lastUpdate
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
            lastUpdateTime: debugInfo.lastUpdate
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        HealthStore.shared.resetUpdateCount()
        
        do {
            let steps = try await HealthStore.shared.fetchSteps(for: currentDate)
            let debugInfo = HealthStore.shared.getDebugInfo()
            
            let entry = SimpleEntry(
                date: currentDate,
                configuration: configuration,
                steps: steps,
                lastError: debugInfo.error,
                updateCount: debugInfo.updateCount,
                lastUpdateTime: debugInfo.lastUpdate
            )
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
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
                    lastUpdateTime: debugInfo.lastUpdate
                )
            ], policy: .after(Date().addingTimeInterval(300)))
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

struct Pea_Widget: Widget {
    let kind: String = "Pea_Widget"
    let creamColor = Color(red: 0.96, green: 0.95, blue: 0.90)

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Pea_WidgetEntryView(entry: entry)
                .containerBackground(creamColor, for: .widget)
        }
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
    SimpleEntry(date: .now, configuration: .smiley,
                steps: 3000, lastError: "none", updateCount: 5, lastUpdateTime: Date())
    SimpleEntry(date: .now, configuration: .starEyes,
                steps: 5000, lastError: "query", updateCount: 6, lastUpdateTime: Date())
}
