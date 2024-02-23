//
//  distanceReport.swift
//  runwithfriends
//
//  Created by Xavier Chia on 23/2/24.
//

import Foundation

struct DistanceReport {
    struct Report {
        let currentStatus: String
        let nextGoal: String
    }
    
    static func getReport(with distance: Int) -> Report {
        let currentStatusPrefix = "You've run \(distance.valueShort)\(distance.metricShort)"
        func nextGoalPrefix(with distanceLeft: Int) -> String {
            "You are \(distanceLeft.valueShort)\(distanceLeft.metricShort) from completing"
        }
        
        switch distance {
        case ..<2300:
            let distanceLeft = 2300 - distance
            let report = Report(currentStatus: "\(currentStatusPrefix)", nextGoal: "\(nextGoalPrefix(with: distanceLeft)) the High Line Park in New York City.")
            return report
        case ..<3000:
            let distanceLeft = 3000 - distance
            let report = Report(currentStatus: "\(currentStatusPrefix) -\n\nThat is more than the High Line Park in New York City!", nextGoal: "\(nextGoalPrefix(with: distanceLeft)) the Golden Gate Bridge in San Francisco.")
            return report
        default:
            return Report(currentStatus: currentStatusPrefix, nextGoal: "You've completed the game!")
        }
    }
}
