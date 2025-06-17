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
import SharedCode

struct DateSteps: Identifiable {
    let id = UUID()
    let date: Date  // Start date of the period
    let steps: Double
}

enum DateRange {
    case currentWeek        // Monday of current week to today
    case rolling(days: Int) // Last N days from today
    case custom(start: Date, end: Date)
    
    // Convenience static properties
    static let rollingWeek = DateRange.rolling(days: 7)
    static let rollingMonth = DateRange.rolling(days: 30)
}

class StepCounter {
    private let pedometer = CMPedometer()
    let healthStore = HKHealthStore()
    private var isAvailable: Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    // Singleton instance
    static let shared = StepCounter()
    
    private init() {}
    
    // New flexible method
    func getStepsForDateRange(_ dateRange: DateRange = .currentWeek) async -> [DateSteps] {
        // Request HealthKit permission first
        let healthKitAuthorized = await requestHealthKitPermission()
        
        // Calculate the actual date range based on the enum
        let calculatedRange = calculateDateRange(for: dateRange)
        
        // Get steps from both sources for the calculated range
        async let healthKitSteps = healthKitAuthorized ? await getStepsFromHealthKit(from: calculatedRange.start, to: calculatedRange.end) : [:]
        async let coreMotionSteps = await getStepsFromCoreMotion(from: calculatedRange.start, to: calculatedRange.end)
        
        // Await both results
        let (hkSteps, cmSteps) = await (healthKitSteps, coreMotionSteps)
        
        // Combine results, taking the higher count for each day
        var combinedSteps = [DateSteps]()
        let calendar = Calendar.current
        let today = Date()
        
        // Generate daily data for the range
        var currentDate = calculatedRange.start
        while currentDate < calculatedRange.end {
            let startOfDay = calendar.startOfDay(for: currentDate)
            
            // Only process days up to today
            if startOfDay <= calendar.startOfDay(for: today) {
                let hkCount = hkSteps[startOfDay] ?? 0
                let cmCount = cmSteps[startOfDay] ?? 0
                let finalCount = max(hkCount, cmCount)
                
                combinedSteps.append(DateSteps(date: startOfDay, steps: finalCount))
                
                // Update widget if this is today
                if calendar.isDateInToday(startOfDay) {
                    updateWidgetData(steps: Int(finalCount), error: "")
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return combinedSteps
    }
    
    // Legacy method for backward compatibility
    func getStepsForWeek() async -> [DateSteps] {
        return await getStepsForDateRange(.currentWeek)
    }
    
    // Helper method to calculate actual dates from enum
    private func calculateDateRange(for dateRange: DateRange) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = Date()
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))!
        
        switch dateRange {
        case .currentWeek:
            // Monday of current week to end of today
            var weekCalendar = Calendar.current
            weekCalendar.firstWeekday = 2  // 2 represents Monday
            let startOfWeek = Date.startOfWeek()
            return (start: startOfWeek, end: endOfToday)
            
        case .rolling(let days):
            // N days back from today
            let startDate = calendar.date(byAdding: .day, value: -days + 1, to: calendar.startOfDay(for: today))!
            return (start: startDate, end: endOfToday)
            
        case .custom(let start, let end):
            // Use provided dates, but ensure end doesn't go beyond today
            let adjustedEnd = min(end, endOfToday)
            return (start: start, end: adjustedEnd)
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
    
    // Request HealthKit permission
    private func requestHealthKitPermission() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToRead = Set([stepType])
        
        do {
            try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: typesToRead)
            return true
        } catch {
            return false
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
        guard let shared = AppDelegate.appUserDefaults else { return }

        shared.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
