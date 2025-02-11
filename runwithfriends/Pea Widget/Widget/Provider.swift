//
//  Provider.swift
//  Pea WidgetExtension
//
//  Created by Xavier Chia PY on 11/2/25.
//

import Foundation
import WidgetKit
import CoreMotion
import HealthKit

struct Provider: AppIntentTimelineProvider {
    let sharedDefaults = UserDefaults(suiteName: "group.com.wholesomeapps.runwithfriends")
    private let pedometer = CMPedometer()
    private let activeRefreshInterval = 15
    private let normalRefreshInterval = 30
    private let stepThreshold = 1000
    
    private func getRefreshInterval(stepDifference: Int, timeSinceLastUpdate: TimeInterval) -> Int {
        let minutesSinceLastUpdate = timeSinceLastUpdate / 60.0
        guard minutesSinceLastUpdate > 0 else {
            return normalRefreshInterval
        }
        let stepsPerMinute = Double(stepDifference) / minutesSinceLastUpdate
        return stepsPerMinute > 33.0 ? activeRefreshInterval : normalRefreshInterval
    }
    
    private func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    private func getStepsFromAllSources() async -> (steps: Int, error: String) {
        let healthStore = HKHealthStore()
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        // Get steps from both sources
        async let coreMotionResult = getStepsFromCoreMotionOnly()
        async let healthKitResult = getStepsFromHealthKit(healthStore: healthStore, stepType: stepType)
        
        // Wait for both results
        let (cmSteps, cmError) = await coreMotionResult
        let (hkSteps, hkError) = await healthKitResult
        
        // Return the higher step count
        if cmSteps > hkSteps {
            return (cmSteps, "CM: \(cmError)")
        } else {
            return (hkSteps, "HK: \(hkError)")
        }
    }

    // Original CoreMotion function renamed
    private func getStepsFromCoreMotionOnly() async -> (steps: Int, error: String) {
        guard isStepCountingAvailable() else {
            return (0, "CM not available")
        }
        
        return await withCheckedContinuation { continuation in
            let startOfDay = Calendar.current.startOfDay(for: Date())
            
            pedometer.queryPedometerData(from: startOfDay, to: Date()) { data, error in
                if let error = error {
                    continuation.resume(returning: (0, error.localizedDescription))
                    return
                }
                
                if let steps = data?.numberOfSteps.intValue {
                    continuation.resume(returning: (steps, "CM success"))
                } else {
                    continuation.resume(returning: (0, "no CM data"))
                }
            }
        }
    }

    // New HealthKit function
    private func getStepsFromHealthKit(healthStore: HKHealthStore, stepType: HKQuantityType) async -> (steps: Int, error: String) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return (0, "HK not available")
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType,
                                        quantitySamplePredicate: predicate,
                                        options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(returning: (0, error.localizedDescription))
                    return
                }
                
                guard let quantity = result?.sumQuantity() else {
                    continuation.resume(returning: (0, "no HK data"))
                    return
                }
                
                let steps = Int(quantity.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: (steps, "HK success"))
            }
            
            healthStore.execute(query)
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
        let data = getDataFromDefaults()
        let (allSteps, allError) = await getStepsFromAllSources()
        updateSharedDefaults(steps: allSteps, error: allError)
        let finalSteps = max(allSteps, data.steps)
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: finalSteps,
            lastError: allError,
            updateCount: data.count + 1,
            lastUpdateTime: Date(),
            family: context.family
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        print("updating widget")
        let currentDate = Date()
        let data = getDataFromDefaults()
        let (allSteps, allError) = await getStepsFromAllSources()
        let maxSteps = max(allSteps, data.steps)
        updateSharedDefaults(steps: maxSteps, error: allError)
        
        let entry = SimpleEntry(
            date: currentDate,
            configuration: configuration,
            steps: maxSteps,
            lastError: allError,
            updateCount: data.count + 1,
            lastUpdateTime: currentDate,
            family: context.family
        )
        
        let timeSinceLastUpdate = currentDate.timeIntervalSince(data.lastUpdate)
        let refreshInterval = getRefreshInterval(
            stepDifference: allSteps - data.steps,
            timeSinceLastUpdate: timeSinceLastUpdate
        )
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: refreshInterval, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

