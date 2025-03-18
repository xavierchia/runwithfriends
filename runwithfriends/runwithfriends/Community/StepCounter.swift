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

struct DailySteps {
    let date: Date
    let steps: Double
}

class StepCounter {
    private let pedometer = CMPedometer()
    private let healthStore = HKHealthStore()
    private var isAvailable: Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    // Singleton instance
    static let shared = StepCounter()
    
    private init() {}
    
    func getStepsForWeek() async -> [DailySteps] {
        // Request HealthKit permission first
        let healthKitAuthorized = await requestHealthKitPermission()
        
        // Get the week's date range
        let weekRange = getWeekToDateRange()
        
        // Get steps from both sources for the whole week
        async let healthKitSteps = healthKitAuthorized ? await getStepsFromHealthKit(from: weekRange.start, to: weekRange.end) : [:]
        async let coreMotionSteps = await getStepsFromCoreMotion(from: weekRange.start, to: weekRange.end)
        
        // Await both results
        let (hkSteps, cmSteps) = await (healthKitSteps, coreMotionSteps)
        
        // Combine results, taking the higher count for each day
        var combinedSteps = [DailySteps]()
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate days between start of week and today (inclusive)
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: weekRange.start), to: calendar.startOfDay(for: today))
        let daysToProcess = min((components.day ?? 0) + 1, 7)
        
        for dayOffset in 0..<daysToProcess {
            let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: weekRange.start)!
            let startOfDay = calendar.startOfDay(for: dayDate)
            
            let hkCount = hkSteps[startOfDay] ?? 0
            let cmCount = cmSteps[startOfDay] ?? 0
            let finalCount = max(hkCount, cmCount)
            
            combinedSteps.append(DailySteps(date: startOfDay, steps: finalCount))
            
            // Update widget if this is today
            if calendar.isDateInToday(startOfDay) {
                updateWidgetData(steps: Int(finalCount), error: "")
            }
        }
        
        return combinedSteps
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
    
    private func getWeekToDateRange() -> (start: Date, end: Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // 2 represents Monday
        
        let today = Date()
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))!        
        let startOfWeek = Date.startOfWeek()

        return (start: startOfWeek, end: endOfToday)
    }
    
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
    
    private func getStepsFromCoreMotion(from startDate: Date, to endDate: Date) async -> [Date: Double] {
        guard isAvailable else {
            return [:]
        }
        
        let calendar = Calendar.current
        
        var stepsDict = [Date: Double]()
        
        // Use Task group to handle concurrent pedometer queries
        await withTaskGroup(of: (Date, Double?).self) { group in
            var currentDate = startDate
            
            // Add a task for each day
            while currentDate < endDate {
                let capturedDate = currentDate
                let dayEnd = min(calendar.date(byAdding: .day, value: 1, to: currentDate)!, endDate)
                
                group.addTask {
                    return await withCheckedContinuation { continuation in
                        self.pedometer.queryPedometerData(from: capturedDate, to: dayEnd) { data, error in
                            if let error = error {
                                print("CoreMotion error: \(error.localizedDescription)")
                                continuation.resume(returning: (capturedDate, nil))
                                return
                            }
                            
                            if let steps = data?.numberOfSteps.doubleValue {
                                continuation.resume(returning: (capturedDate, steps))
                            } else {
                                continuation.resume(returning: (capturedDate, nil))
                            }
                        }
                    }
                }
                
                currentDate = dayEnd
            }
            
            // Collect results from all tasks, only adding non-nil values
            for await (date, steps) in group {
                if let steps = steps {
                    stepsDict[date] = steps
                }
            }
        }
                
        return stepsDict
    }
    
    private func getStepsFromHealthKit(from startDate: Date, to endDate: Date) async -> [Date: Double] {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return [:]
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let stepsThisWeek = HKSamplePredicate.quantitySample(type: stepType, predicate: predicate)
        
        // Set up date intervals for collection query - daily intervals
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: startDate)
        
        let daily = DateComponents(day: 1)
        
        let queryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: stepsThisWeek,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: daily
        )
        
        return await withCheckedContinuation { continuation in
            Task {
                do {
                    let results = try await queryDescriptor.result(for: healthStore)
                    var stepsDict = [Date: Double]()
                    
                    results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                        if let quantity = statistics.sumQuantity() {
                            let steps = quantity.doubleValue(for: HKUnit.count())
                            stepsDict[statistics.startDate] = steps
                        } else {
                            stepsDict[statistics.startDate] = 0
                        }
                    }
                                        
                    continuation.resume(returning: stepsDict)
                } catch {
                    print("HealthKit query error: \(error.localizedDescription)")
                    continuation.resume(returning: [:])
                }
            }
        }
    }
    
    private func updateWidgetData(steps: Int, error: String) {
        guard let shared = UserDefaults(suiteName: "group.com.wholesomeapps.runwithfriends") else { return }
        
        if let lastUpdate = shared.object(forKey: "lastUpdateTime") as? Date {
            let isNewDay = !Calendar.current.isDate(lastUpdate, inSameDayAs: Date())
            if isNewDay {
                shared.set(Date(), forKey: "lastUpdateTime")
            }
        }

        shared.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
