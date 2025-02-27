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
    private static var lastUpdate = Date().addingTimeInterval(-20)
    private static var lastNetworkUpdate = Date().addingTimeInterval(-20)
    
    private func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    private func getStepsFromAllSources() async -> (steps: Int, error: String) {
        // Get steps from both sources
        async let coreMotionResult = getStepsFromCoreMotionOnly()
        async let healthKitResult = getStepsFromHealthKit()
        
        // Wait for both results
        let ((cmSteps, cmError), (hkSteps, hkError)) = await (coreMotionResult, healthKitResult)
        
        // Return the higher step count
        if cmSteps > hkSteps {
            return (cmSteps, "CM: \(cmError)")
        } else {
            return (hkSteps, "HK: \(hkError)")
        }
    }
    
    // TODO: We can use continuation.throw to throw an error and handle it later, widget should show error if necessary
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
    
    private func getDataFromDefaults() -> Int {
        guard let shared = sharedDefaults else {
            print("no shared defaults")
            return 0
        }
        
        let steps = shared.integer(forKey: "userDaySteps")
        return steps
    }
    
    private func getCurrentData() async -> (steps: Int, error: String) {
        let (allSteps, allError) = await getStepsFromAllSources()
        var steps = getDataFromDefaults()
        steps = max(allSteps, steps)
        
        let isNewDay = !Calendar.current.isDate(Provider.lastUpdate, inSameDayAs: Date())
        if isNewDay {
            steps = 0
        }
        
        return (steps, allError)
    }
    
    private func updateSharedDefaults(steps: Int? = nil) {
        guard let shared = sharedDefaults else {
            print("no shared defaults")
            return
        }
        
        if let steps {
            shared.set(steps, forKey: "userDaySteps")
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
        let steps = getDataFromDefaults()
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            steps: steps,
            family: context.family,
            firstFriend: nil
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        print("snapshot called")
        let data = await getCurrentData()
        updateSharedDefaults(steps: data.steps)
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: data.steps,
            family: context.family,
            firstFriend: getFirstFriend()
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let data = await getCurrentData()
        print("updating widget \(context.family) lastUpdate: \(Provider.lastUpdate.timeIntervalSinceNow) lastNetworkUpdate: \(Provider.lastNetworkUpdate.timeIntervalSinceNow)")
        
        if context.family == .systemSmall,
           Provider.lastNetworkUpdate.timeIntervalSinceNow < -5 {
            async let upsert: () = await Supabase.shared.upsert(steps: data.steps)
            async let getFriends: () = await Supabase.shared.getFriends()
            _ = await (upsert, getFriends)
            Provider.lastNetworkUpdate = Date()
        } else {
            print("failed to upsert and get friends \(context.family) lastUpdate: \(Provider.lastUpdate.timeIntervalSinceNow) lastNetworkUpdate: \(Provider.lastNetworkUpdate.timeIntervalSinceNow)")
        }
        
        updateSharedDefaults(steps: data.steps)
        Provider.lastUpdate = Date()

        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: data.steps,
            family: context.family,
            firstFriend: getFirstFriend()
        )
            
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

