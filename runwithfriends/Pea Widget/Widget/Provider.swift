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
    private let healthStore = HKHealthStore()
    
    private func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    private func getStepsFromAllSources() async -> (steps: Int, error: String) {
        // Get steps from both sources
        async let coreMotionResult = getStepsFromCoreMotionOnly()
        async let healthKitResult = getStepsFromHealthKit()
        
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
    private func getStepsFromHealthKit() async -> (steps: Int, error: String) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKHealthStore.isHealthDataAvailable() else {
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
            
            self.healthStore.execute(query)
        }
    }
    
    private func getDataFromDefaults() -> (steps: Int, error: String, count: Int, lastUpdate: Date) {
        guard let shared = sharedDefaults else {
            print("no shared defaults")
            return (0, "no shared defaults", 0, Date())
        }
        
        let steps = shared.integer(forKey: "userDaySteps")
        let lastError = shared.string(forKey: "lastError") ?? "none"
        let updateCount = shared.integer(forKey: "updateCount")
        let lastUpdate = shared.object(forKey: "lastUpdateTime") as? Date ?? Date()
        
        return (steps, lastError, updateCount, lastUpdate)
    }
    
    private func getCurrentData() async -> (steps: Int, error: String, count: Int, lastUpdate: Date, isNewSteps: Bool) {
        let (allSteps, allError) = await getStepsFromAllSources()
        let data = getDataFromDefaults()
        
        var steps = data.steps
        var count = data.count
        var isNewSteps = false
        
        if data.steps != allSteps {
            steps = max(allSteps, data.steps)
            count = data.count + 1
            isNewSteps = true
        }

        let isNewDay = !Calendar.current.isDate(data.lastUpdate, inSameDayAs: Date())
        if isNewDay {
            steps = 0
            count = 1
            isNewSteps = true
        }
        
        return (steps, allError, count, data.lastUpdate, isNewSteps)
    }
    
    private func updateSharedDefaults(steps: Int, error: String, count: Int) {
        guard let shared = sharedDefaults else {
            print("no shared defaults")
            return
        }
    
        shared.set(steps, forKey: "userDaySteps")
        shared.set(error, forKey: "lastError")
        shared.set(count, forKey: "updateCount")
        shared.set(Date(), forKey: "lastUpdateTime")

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
        let data = await getCurrentData()
        updateSharedDefaults(steps: data.steps, error: data.error, count: data.count)
        return SimpleEntry(
            date: data.lastUpdate,
            configuration: configuration,
            steps: data.steps,
            lastError: data.error,
            updateCount: data.count,
            lastUpdateTime: Date(),
            family: context.family,
            firstFriend: getFirstFriend()
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        print("updating widget")
        
        let data = await getCurrentData()
        
        if data.lastUpdate.timeIntervalSinceNow < -5 {
            if data.isNewSteps {
                await Supabase.shared.upsert(steps: data.steps)
            }
            
            await Supabase.shared.getFriends()
        }

        updateSharedDefaults(steps: data.steps, error: data.error, count: data.count)
        let entry = SimpleEntry(
            date: data.lastUpdate,
            configuration: configuration,
            steps: data.steps,
            lastError: data.error,
            updateCount: data.count,
            lastUpdateTime: Date(),
            family: context.family,
            firstFriend: getFirstFriend()
        )
        
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

