//
//  GraphMachine.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 20/5/25.
//

import Foundation
import HealthKit

struct GraphMachine {
    static let shared = GraphMachine()
    private init() {}
    
    func getSteps12Weeks() async -> [DateSteps] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // 2 represents Monday
        
        // Calculate date ranges
        let currentWeekStart = Date.startOfWeek() // Your existing method to get Monday of current week
        let elevenWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -11, to: currentWeekStart)!
        let lastWeekEnd = calendar.date(byAdding: .day, value: -1, to: currentWeekStart)!
        
        // 1. Get historical data (weeks 1-11) using efficient HealthKit weekly query
        var historicalWeeks = await getHealthkitWeeklySteps(from: elevenWeeksAgo, to: lastWeekEnd)
        
        // 2. Get current week data using existing method
        let currentWeekDailySteps = await StepCounter.shared.getStepsForWeek()
        
        // 3. Aggregate current week data
        let currentWeekSteps = currentWeekDailySteps.reduce(0) { sum, dailySteps in
            return sum + dailySteps.steps
        }
        
        // 4. Add current week to results
        let currentWeekData = DateSteps(date: currentWeekStart, steps: currentWeekSteps)
        historicalWeeks.append(currentWeekData)
        
        return historicalWeeks
    }

    // Helper method for efficient weekly HealthKit query for historical data
    private func getHealthkitWeeklySteps(from startDate: Date, to endDate: Date) async -> [DateSteps] {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return []
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let stepsQuery = HKSamplePredicate.quantitySample(type: stepType, predicate: predicate)
        
        // Set up date intervals for collection query with Monday-based weeks
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // Explicitly set Monday as first day of week
        
        // Ensure anchorDate is a Monday
        let anchorDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate))!
        
        // Use weekly interval
        let weekly = DateComponents(weekOfYear: 1)
        
        let queryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: stepsQuery,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: weekly
        )
        
        return await withCheckedContinuation { continuation in
            Task {
                do {
                    let results = try await queryDescriptor.result(for: StepCounter.shared.healthStore)
                    var weeklySteps = [DateSteps]()
                    
                    results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                        // Ensure we have Monday as the start date for each week
                        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: statistics.startDate))!
                        
                        if let quantity = statistics.sumQuantity() {
                            let steps = quantity.doubleValue(for: HKUnit.count())
                            weeklySteps.append(DateSteps(date: weekStart, steps: steps))
                        } else {
                            weeklySteps.append(DateSteps(date: weekStart, steps: 0))
                        }
                    }
                    
                    continuation.resume(returning: weeklySteps)
                } catch {
                    print("HealthKit weekly query error: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
}
