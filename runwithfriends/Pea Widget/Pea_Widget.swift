import WidgetKit
import SwiftUI
import HealthKit

class HealthStore {
    static let shared = HealthStore()
    let healthStore = HKHealthStore()
    
    func fetchSteps(for date: Date) async throws -> Int {
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
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), steps: 0)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, steps: 3000)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        do {            
            let currentDate = Date()
            let steps = try await HealthStore.shared.fetchSteps(for: currentDate)
            
            let entry = SimpleEntry(date: currentDate, configuration: configuration, steps: steps)
            entries.append(entry)
            
            // Update every 30 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            return Timeline(entries: entries, policy: .after(nextUpdate))
            
        } catch {
            print("Error fetching health data: \(error.localizedDescription)")
            return Timeline(entries: [
                SimpleEntry(date: Date(), configuration: configuration, steps: 0)
            ], policy: .after(Date().addingTimeInterval(3600)))
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let steps: Int
}

struct Pea_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Keep Walking")
                .font(.headline)
            Text("\(entry.steps) steps")
                .font(.subheadline)
        }
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
    SimpleEntry(date: .now, configuration: .smiley, steps: 3000)
    SimpleEntry(date: .now, configuration: .starEyes, steps: 5000)
}
