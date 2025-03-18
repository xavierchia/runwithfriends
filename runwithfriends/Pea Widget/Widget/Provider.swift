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
    static var networkUpdateCount = 0
    
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
        
        if let lastUpdate = sharedDefaults?.object(forKey: "lastUpdate") as? Date {
            let isNewDay = !Calendar.current.isDate(lastUpdate, inSameDayAs: Date())
            if isNewDay {
                steps = 0
            }
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

    func placeholder(in context: Context) -> SimpleEntry {
        let steps = getDataFromDefaults()
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            steps: steps,
            family: context.family
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
            family: context.family
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let data = await getCurrentData()
        
        await doNetworking(context: context, steps: data.steps)
        
//        print("xxavier \(try? await Supabase.shared.client.auth.session)")
        
        Provider.networkUpdateCount += 1
        
        updateSharedDefaults(steps: data.steps)
        sharedDefaults?.set(Date(), forKey: "lastUpdate")

        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: data.steps,
            family: context.family
        )
            
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    private func doNetworking(context: Context, steps: Int) async {
        
        guard context.family == .systemSmall else {
            return
        }
                
        if let lastNetworkUpdate = sharedDefaults?.object(forKey: "lastNetworkUpdate") as? Date,
           lastNetworkUpdate.timeIntervalSinceNow < -20,
           Provider.networkUpdateCount % 2 == 0 {
            await Supabase.shared.setSessionIfNeeded()
            async let upsertResult: () = await Supabase.shared.upsert(steps: steps)
            async let publicUsersResult = await Supabase.shared.getPublicUsers()
            let (_, publicUsers) = await (upsertResult, publicUsersResult)
//            print(publicUsers)
            sharedDefaults?.set(Date(), forKey: "lastNetworkUpdate")
        }
    }
}

