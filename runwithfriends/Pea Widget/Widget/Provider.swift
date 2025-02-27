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
    
    init() {
        Task {
            _ = await Supabase.shared.client.auth.onAuthStateChange { event, session in
                print("auth state change event \(event)")
                switch event {
                case .signedOut:
                    try? KeychainManager.shared.deleteTokens()
                    print("User signed out. Session ended.")
                default:
                    guard let session else { return }
                    try? KeychainManager.shared.saveTokens(accessToken: session.accessToken,
                                                           refreshToken: session.refreshToken)
                }
            }
        }
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
    
    private func getDataFromDefaults() -> (steps: Int, lastUpdate: Date) {
        guard let shared = sharedDefaults else {
            print("no shared defaults")
            return (0, Date())
        }
        
        let steps = shared.integer(forKey: "userDaySteps")
        let lastUpdate = shared.object(forKey: "lastUpdateTime") as? Date ?? Date()
        
        return (steps, lastUpdate)
    }
    
    private func getCurrentData() async -> (steps: Int, error: String, lastUpdate: Date) {
        let (allSteps, allError) = await getStepsFromAllSources()
        let data = getDataFromDefaults()
        
        var steps = data.steps
        
        if data.steps != allSteps {
            steps = max(allSteps, data.steps)
        }

        let isNewDay = !Calendar.current.isDate(data.lastUpdate, inSameDayAs: Date())
        if isNewDay {
            steps = 0
        }
        
        return (steps, allError, data.lastUpdate)
    }
    
    private func updateSharedDefaults(steps: Int, error: String) {
        guard let shared = sharedDefaults else {
            print("no shared defaults")
            return
        }
    
        shared.set(steps, forKey: "userDaySteps")
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
            lastUpdateTime: data.lastUpdate,
            family: context.family,
            firstFriend: nil
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        print("snapshot called")
        let data = await getCurrentData()
        updateSharedDefaults(steps: data.steps, error: data.error)
        return SimpleEntry(
            date: data.lastUpdate,
            configuration: configuration,
            steps: data.steps,
            lastUpdateTime: Date(),
            family: context.family,
            firstFriend: getFirstFriend()
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        print("updating widget")
        
        let data = await getCurrentData()
        
        if context.family == .systemSmall,
           data.lastUpdate.timeIntervalSinceNow < -5 {
                async let upsert: () = await Supabase.shared.upsert(steps: data.steps)
                async let getFriends: () = await Supabase.shared.getFriends()
                
                _ = await (upsert, getFriends)
        }

        updateSharedDefaults(steps: data.steps, error: data.error)
        let entry = SimpleEntry(
            date: data.lastUpdate,
            configuration: configuration,
            steps: data.steps,
            lastUpdateTime: Date(),
            family: context.family,
            firstFriend: getFirstFriend()
        )
            
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

