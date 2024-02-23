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
        case ..<Landmarks.HighLineNewYork:
            let distanceLeft = Landmarks.HighLineNewYork - distance
            let report = Report(currentStatus: "\(currentStatusPrefix) -\n\n That is more than \(Int(distance / Landmarks.EiffelTower)) Eiffel Towers in Paris!", nextGoal: "\(nextGoalPrefix(with: distanceLeft)) the High Line Park in New York City.")
            return report
        case ..<Landmarks.GoldenGateBridge:
            let distanceLeft = Landmarks.GoldenGateBridge - distance
            let report = Report(currentStatus: "\(currentStatusPrefix) -\n\nThat is more than the High Line Park in New York City!", nextGoal: "\(nextGoalPrefix(with: distanceLeft)) the Golden Gate Bridge in San Francisco.")
            return report
        default:
            return Report(currentStatus: currentStatusPrefix, nextGoal: "You've completed the game!")
        }
    }
}

struct Landmarks {
    static let EiffelTower = 330
    static let HighLineNewYork = 2300
    static let GoldenGateBridge = 2737
}
