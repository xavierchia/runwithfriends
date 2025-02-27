//
//  StepCounter.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 11/2/25.
//

import CoreLocation
import HealthKit
import WidgetKit
import CoreMotion

class StepCounter {
    private let pedometer = CMPedometer()
    private let healthStore = HKHealthStore()
    private var isAvailable: Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    // Singleton instance
    static let shared = StepCounter()
    
    private init() {}
    
    // Request HealthKit permission
    private func requestHealthKitPermission() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToRead = Set([stepType])
        
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    // Check and request motion permissions
    func requestMotionPermission(completion: @escaping (Bool) -> Void) {
        guard isAvailable else {
            completion(false)
            return
        }
        
        pedometer.queryPedometerData(from: Date(), to: Date()) { _, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    switch error.code {
                    case Int(CMErrorMotionActivityNotAuthorized.rawValue):
                        completion(false)
                    default:
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            }
        }
    }
    
    // Get steps from CoreMotion
    private func getStepsFromCoreMotion(from startDate: Date) async -> (steps: Double, error: String) {
        guard isAvailable else {
            return (0, "CM not available")
        }
        
        return await withCheckedContinuation { continuation in
            pedometer.queryPedometerData(from: startDate, to: Date()) { data, error in
                if let error = error {
                    continuation.resume(returning: (0, error.localizedDescription))
                    return
                }
                
                if let steps = data?.numberOfSteps.doubleValue {
                    continuation.resume(returning: (steps, "CM success"))
                } else {
                    continuation.resume(returning: (0, "no CM data"))
                }
            }
        }
    }
    
    // Get steps from HealthKit
    private func getStepsFromHealthKit(from startDate: Date) async -> (steps: Double, error: String) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return (0, "HK not available")
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
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
                
                let steps = quantity.doubleValue(for: HKUnit.count())
                continuation.resume(returning: (steps, "HK success"))
            }
            
            healthStore.execute(query)
        }
    }
    
    // Main function to get steps from both sources
    func getSteps(from startDate: Date, source: String = "app", completion: @escaping (Double) -> Void) {
        Task {
            // Request HealthKit permission first
            let healthKitAuthorized = await requestHealthKitPermission()
            
            // Get steps from both sources
            async let coreMotionResult = getStepsFromCoreMotion(from: startDate)
            async let healthKitResult = healthKitAuthorized ? getStepsFromHealthKit(from: startDate) : (steps: 0.0, error: "HK not authorized")
            
            let (cmSteps, cmError) = await coreMotionResult
            let (hkSteps, hkError) = await healthKitResult
            
            // Use the higher step count
            let finalSteps = max(cmSteps, hkSteps)
            let error = cmSteps > hkSteps ? "CM: \(cmError)" : "HK: \(hkError)"
            
            // Update widget if needed
            if Calendar.current.isDate(startDate, inSameDayAs: Date()) {
                updateWidgetData(steps: Int(finalSteps), error: error)
            }
            
            // Return the result on the main thread
            DispatchQueue.main.async {
                completion(finalSteps)
            }
        }
    }

    private func updateWidgetData(steps: Int, error: String) {
        guard let shared = UserDefaults(suiteName: "group.com.wholesomeapps.runwithfriends") else { return }
        
        let currentSteps = shared.integer(forKey: "userDaySteps")
        let lastUpdate = shared.object(forKey: "lastUpdateTime") as? Date ?? Date()
        
        let isNewDay = !Calendar.current.isDate(lastUpdate, inSameDayAs: Date())
        if isNewDay {
        }
        if steps != currentSteps {
            shared.set(steps, forKey: "userDaySteps")
            shared.set(Date(), forKey: "lastUpdateTime")
        }
        shared.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // Live updates functionality
    private var updateHandlers: [UUID: (Double) -> Void] = [:]
    
    func startLiveUpdates(handler: @escaping (Double) -> Void) -> UUID {
        let id = UUID()
        updateHandlers[id] = handler
        
        guard isAvailable else { return id }
        
        requestMotionPermission { authorized in
            guard authorized else { return }
            
            self.pedometer.startUpdates(from: Date()) { [weak self] data, error in
                if let steps = data?.numberOfSteps.doubleValue {
                    DispatchQueue.main.async {
                        self?.updateHandlers.values.forEach { $0(steps) }
                    }
                }
            }
        }
        
        return id
    }
    
    func stopLiveUpdates(id: UUID) {
        updateHandlers.removeValue(forKey: id)
        if updateHandlers.isEmpty {
            pedometer.stopUpdates()
        }
    }
}
