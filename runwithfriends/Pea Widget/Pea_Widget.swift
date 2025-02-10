import WidgetKit
import SwiftUI
import CoreMotion

// Keep the entry struct the same
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
    let sharedDefaults = UserDefaults(suiteName: "group.com.wholesomeapps.runwithfriends")
    private let pedometer = CMPedometer()
    private let activeRefreshInterval = 15
    private let normalRefreshInterval = 30
    private let stepThreshold = 1000
    
    private func getRefreshInterval(stepDifference: Int, timeSinceLastUpdate: TimeInterval) -> Int {
        // Convert time difference to minutes
        let minutesSinceLastUpdate = timeSinceLastUpdate / 60.0
        
        // Avoid division by zero
        guard minutesSinceLastUpdate > 0 else {
            return normalRefreshInterval
        }
        
        // Calculate steps per minute
        let stepsPerMinute = Double(stepDifference) / minutesSinceLastUpdate
        
        // Return shorter interval if step rate is high (> 33 steps/minute)
        return stepsPerMinute > 33.0 ? activeRefreshInterval : normalRefreshInterval
    }
    
    private func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    private func getStepsFromCoreMotion(currentSteps: Int) async -> (steps: Int, error: String) {
        guard isStepCountingAvailable() else {
            return (currentSteps, "step counting not available")
        }
        
        return await withCheckedContinuation { continuation in
            let startOfDay = Calendar.current.startOfDay(for: Date())
            
            pedometer.queryPedometerData(from: startOfDay, to: Date()) { data, error in
                if let error = error {
                    continuation.resume(returning: (currentSteps, error.localizedDescription))
                    return
                }
                
                if let steps = data?.numberOfSteps.intValue {
                    continuation.resume(returning: (steps, "widget success"))
                } else {
                    continuation.resume(returning: (currentSteps, "no step data"))
                }
            }
        }
    }
    
    private func getDataFromDefaults() -> (steps: Int, error: String, count: Int, lastUpdate: Date) {
        guard let shared = sharedDefaults else {
            return (0, "no shared defaults", 0, Date())
        }
        
        let steps = shared.integer(forKey: "userDaySteps")
        let updateCount = shared.integer(forKey: "updateCount")
        let lastError = shared.string(forKey: "lastError") ?? "none"
        let lastUpdate = shared.object(forKey: "lastUpdateTime") as? Date ?? Date()
        
        return (steps, lastError, updateCount, lastUpdate)
    }
    
    private func updateSharedDefaults(steps: Int, error: String) {
        guard let shared = sharedDefaults else { return }
        
        let currentSteps = shared.integer(forKey: "userDaySteps")
        let currentCount = shared.integer(forKey: "updateCount")
        
        // Check if it's a new day
        let lastUpdate = shared.object(forKey: "lastUpdateTime") as? Date ?? Date()
        let isNewDay = !Calendar.current.isDate(lastUpdate, inSameDayAs: Date())
        
        if isNewDay {
            // Reset everything at the start of a new day, but use current steps
            shared.set(steps, forKey: "userDaySteps")
            shared.set(Date(), forKey: "lastUpdateTime")
            shared.set(1, forKey: "updateCount")
            shared.set("new day", forKey: "lastError")
            shared.synchronize()
        } else if steps > currentSteps {
            // Update only if new step count is higher
            shared.set(steps, forKey: "userDaySteps")
            shared.set(Date(), forKey: "lastUpdateTime")
            shared.set(currentCount + 1, forKey: "updateCount")
            shared.set(error, forKey: "lastError")
            shared.synchronize()
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let data = getDataFromDefaults()
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            steps: data.steps,
            lastError: data.error,
            updateCount: data.count,
            lastUpdateTime: data.lastUpdate,
            family: context.family
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        // Get current data from defaults first
        let data = getDataFromDefaults()
        
        // Get steps from CoreMotion, passing current steps for fallback
        let (motionSteps, motionError) = await getStepsFromCoreMotion(currentSteps: data.steps)
        
        // Update shared defaults with new step count if necessary
        updateSharedDefaults(steps: motionSteps, error: motionError)
        
        // Use the higher value between stored and new steps
        let finalSteps = max(motionSteps, data.steps)
        
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: finalSteps,
            lastError: motionError,
            updateCount: data.count,
            lastUpdateTime: Date(),
            family: context.family
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        print("updating widget")
        let currentDate = Date()
        
        // Get current data from defaults first
        let data = getDataFromDefaults()
        
        // Get steps from CoreMotion, passing current steps for fallback
        let (motionSteps, motionError) = await getStepsFromCoreMotion(currentSteps: data.steps)
        
        // Update shared defaults with new step count if necessary
        updateSharedDefaults(steps: motionSteps, error: motionError)
        
        // Use the higher value between stored and new steps
        let finalSteps = max(motionSteps, data.steps)
        
        let entry = SimpleEntry(
            date: currentDate,
            configuration: configuration,
            steps: finalSteps,
            lastError: motionError,
            updateCount: data.count,
            lastUpdateTime: currentDate,
            family: context.family
        )
        
        // Calculate time since last update
        let timeSinceLastUpdate = currentDate.timeIntervalSince(data.lastUpdate)
        
        // Get refresh interval based on step rate
        let refreshInterval = getRefreshInterval(
            stepDifference: motionSteps - data.steps,
            timeSinceLastUpdate: timeSinceLastUpdate
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: refreshInterval, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// Keep your existing view code unchanged
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

// Preview configurations remain unchanged
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
