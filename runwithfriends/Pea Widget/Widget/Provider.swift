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
            print("no shared defaults")
            return (0, "no shared defaults", 0, Date())
        }
        
        let steps = shared.integer(forKey: "userDaySteps")
        let updateCount = shared.integer(forKey: "updateCount")
        let lastError = shared.string(forKey: "lastError") ?? "none"
        let lastUpdate = shared.object(forKey: "lastUpdateTime") as? Date ?? Date()
        
        return (steps, lastError, updateCount, lastUpdate)
    }
    
    private func updateSharedDefaults(steps: Int, error: String) {
        guard let shared = sharedDefaults else {
            print("no shared defaults")
            return
        }
        
        let currentSteps = shared.integer(forKey: "userDaySteps")
        let currentCount = shared.integer(forKey: "updateCount")
        
        let lastUpdate = shared.object(forKey: "lastUpdateTime") as? Date ?? Date()
        let isNewDay = !Calendar.current.isDate(lastUpdate, inSameDayAs: Date())
        if isNewDay {
            shared.set(1, forKey: "updateCount")
        }
        if steps != currentSteps {
            shared.set(steps, forKey: "userDaySteps")
            shared.set(Date(), forKey: "lastUpdateTime")
            shared.set(currentCount + 1, forKey: "updateCount")
            shared.set(error, forKey: "lastError")
        }
        shared.synchronize()
    }
    
    private func getFirstFriend() -> FriendProgress? {
        guard let shared = sharedDefaults,
              let friendData = shared.data(forKey: "friendsProgress") else {
            print("no shared defaults")
            return nil
        }
        
        do {
            let friends = try JSONDecoder().decode([FriendProgress].self, from: friendData)
            return friends.first
        } catch {
            print("Failed to load friends data: \(error)")
            return nil
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
            family: context.family,
            firstFriend: nil
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        print("snapshot called")
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
            family: context.family,
            firstFriend: getFirstFriend()
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
            family: context.family,
            firstFriend: getFirstFriend()
        )
        
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

