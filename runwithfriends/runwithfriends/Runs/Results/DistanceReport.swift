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
        let nextDistance: String
        let nextAchievement: String
    }
    
    static func getReport(with distance: Int) -> Report {
        let currentDistance = "You've run \(distance.valueShort)\(distance.metricShort) -"
        func nextDistance(with distanceLeft: Int) -> String {
            "You are \(distanceLeft.valueShort)\(distanceLeft.metricShort) from -"
        }
        
        switch distance {
        case ..<Landmarks.HighLineNewYork:
            let distanceLeft = Landmarks.HighLineNewYork - distance
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than \(Int(distance / Landmarks.EiffelTower)) eiffel towers in paris!",
                                nextDistance: nextDistance(with: distanceLeft),
                                nextAchievement: "The high line park in new york city.")
            return report
        case ..<Landmarks.GoldenGateBridge:
            let distanceLeft = Landmarks.GoldenGateBridge - distance
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the high line park in new york city!",
                                nextDistance: nextDistance(with: distanceLeft),
                                nextAchievement: "The golden gate bridge in san francisco.")
            return report
        default:
            return Report(currentDistance: currentDistance,
                          currentAchievement: "",
                          nextDistance: "",
                          nextAchievement: "You have completed the game")
        }
    }
}

struct Landmarks {
    static let EiffelTower = 330
    static let HighLineNewYork = 2300
    static let GoldenGateBridge = 2737
}
