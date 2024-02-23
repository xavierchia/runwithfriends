//
//  distanceReport.swift
//  runwithfriends
//
//  Created by Xavier Chia on 23/2/24.
//

import Foundation
import UIKit

struct DistanceReport {
    struct Report {
        let currentDistance: NSAttributedString
        let currentAchievement: String
        let nextDistance: NSAttributedString
        let nextAchievement: String
    }
    
    enum ReportType {
        case currentDistance
        case nextDistance
    }
        
    static func getReport(with distance: Int) -> Report {
            
        func getColoredString(with reportType: ReportType, and distance: Int) -> NSAttributedString {
            let mainString: String
            let distanceWord = distanceWords.shuffled().first ?? "Distance"
            switch reportType {
            case .currentDistance:
                mainString = "\(distanceWord): \(distance.valueShort) \(distance.metricShort)"
            case .nextDistance:
                mainString = "Just \(distance.valueShort) \(distance.metricShort) away from:"
            }
            
            let stringToColor = "\(distance.valueShort) \(distance.metricShort)"
            let range = (mainString as NSString).range(of: stringToColor)
            let distanceString = NSMutableAttributedString.init(string: mainString)
            distanceString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.pumpkin, range: range)
            return distanceString
        }
                
        let currentDistance = getColoredString(with: .currentDistance, and: distance)
        
        switch distance {
        case ..<Landmarks.HighLineNewYork:
            let distanceLeft = Landmarks.HighLineNewYork - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than \(Int(distance / Landmarks.EiffelTower)) Eiffel Towers in Paris!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the High Line Park in New York City.")
            return report
        case ..<Landmarks.GoldenGateBridge:
            let distanceLeft = Landmarks.GoldenGateBridge - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the High Line Park in New York City!",
                                nextDistance: nextDistance,
                                nextAchievement: "The Golden Gate Bridge in San Francisco.")
            return report
        default:
            return Report(currentDistance: currentDistance,
                          currentAchievement: "You have completed the game",
                          nextDistance: NSAttributedString(),
                          nextAchievement: "You have completed the game")
        }
    }
}

struct Landmarks {
    static let EiffelTower = 330
    static let HighLineNewYork = 2300
    static let GoldenGateBridge = 2737
}

let distanceWords = [
    "Distance",
    "Explored",
    "Journeyed",
    "Roamed",
    "Trekked",
    "Ventured",
    "Wandered",
    "Traversed",
    "Meandered",
    "Hiked",
    "Sauntered",
    "Trod",
    "Sojourned",
    "Voyaged",
    "Strolled",
    "Ambled",
    "Treaded",
    "Plodded",
    "Cruised",
    "Zipped",
    "Strided",
    "Scuttled"
]
