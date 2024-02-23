//
//  distanceReport.swift
//  runwithfriends
//
//  Created by Xavier Chia on 23/2/24.
//

import Foundation

struct DistanceReport {
    struct Report {
        let currentDistance: String
        let currentAchievement: String
        let nextAchievement: String
    }
    
    static func getReport(with distance: Int) -> Report {
        let currentDistance = "You've run \(distance.valueShort)\(distance.metricShort) -"
        func nextGoalPrefix(with distanceLeft: Int) -> String {
            "You are \(distanceLeft.valueShort)\(distanceLeft.metricShort) from completing"
        }
        
        switch distance {
        case ..<Landmarks.HighLineNewYork:
            let distanceLeft = Landmarks.HighLineNewYork - distance
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That is more than \(Int(distance / Landmarks.EiffelTower)) Eiffel Towers in Paris!\n",
                                nextAchievement: "\(nextGoalPrefix(with: distanceLeft)) the High Line Park in New York City.\n")
            return report
        case ..<Landmarks.GoldenGateBridge:
            let distanceLeft = Landmarks.GoldenGateBridge - distance
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That is more than the High Line Park in New York City!\n",
                                nextAchievement: "\(nextGoalPrefix(with: distanceLeft)) the Golden Gate Bridge in San Francisco.\n")
            return report
        default:
            return Report(currentDistance: currentDistance, currentAchievement: "", nextAchievement: "You have completed the game\n")
        }
    }
}

struct Landmarks {
    static let EiffelTower = 330
    static let HighLineNewYork = 2300
    static let GoldenGateBridge = 2737
}
