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
        case ..<Landmark.HighLineNewYork.info.distance:
            let distanceLeft = Landmark.HighLineNewYork.info.distance - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than \(Int(distance / Landmark.EiffelTower.info.distance)) Eiffel Towers in Paris!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the High Line Park in New York City.")
            return report
        case ..<Landmark.GoldenGateBridge.info.distance:
            let distanceLeft = Landmark.GoldenGateBridge.info.distance - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the High Line Park in New York City!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the Golden Gate Bridge in San Francisco.")
            return report
        case ..<Landmark.MountFuji.info.distance:
            let distanceLeft = Landmark.MountFuji.info.distance - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the Golden Gate Bridge in San Francisco!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing Mount Fuji in Japan.")
            return report
        case ..<Landmark.HydePark.info.distance:
            let distanceLeft = Landmark.HydePark.info.distance - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the height of Mount Fuji in Japan!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the Hyde Park big loop in London.")
            return report
        case ..<Landmark.CentralPark.info.distance:
            let distanceLeft = Landmark.CentralPark.info.distance - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the Hyde Park big loop in London!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the Central Park big loop in New York!")
            return report
        case ..<Landmark.LakeGarda.info.distance:
            let distanceLeft = Landmark.LakeGarda.info.distance - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the Central Park big loop in New York!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the width of Lake Garda in Italy.")
            return report
        case ..<Landmark.Manhattan.info.distance:
            let distanceLeft = Landmark.Manhattan.info.distance - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the width of Lake Garda in Italy!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the length of Manhattan in New York!")
            return report
        case ..<Landmark.CERN.info.distance:
            let distanceLeft = Landmark.CERN.info.distance - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the length of Manhattan in New York!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the circumference of the CERN Hadron Collider near Geneva Switzerland.\n")
            return report
        default:
            return Report(currentDistance: currentDistance,
                          currentAchievement: "You have completed the game",
                          nextDistance: NSAttributedString(),
                          nextAchievement: "You have completed the game")
        }
    }
}

struct DistanceTable {
    static func getDistanceTableRows(for distance: Int) -> [Landmark] {
        var distanceTableRows = [Landmark]()
        
        for landmark in Landmark.allCases {
            if landmark.info.distance <= distance {
                distanceTableRows.append(landmark)
            } else {
                distanceTableRows.append(landmark)
                break
            }
        }
        
        distanceTableRows.sort { lhs, rhs in
            lhs.info.distance > rhs.info.distance
        }
        
        return distanceTableRows
    }
}

enum Landmark: CaseIterable {
    case EiffelTower
    case HighLineNewYork
    case GoldenGateBridge
    case MountFuji
    case HydePark
    case CentralPark
    case LakeGarda
    case Manhattan
    case CERN
    
    var info: (distance: Int, name: String, emoji: String) {
        switch self {
        case .EiffelTower:
            return (330, "Eiffel Tower", "🥐")
        case .HighLineNewYork:
            return (2300, "High Line Park", "🛤️")
        case .GoldenGateBridge:
            return (2737, "Golden Gate Bridge", "🌉")
        case .MountFuji:
            return (3776, "Mount Fuji", "🗻")
        case .HydePark:
            return (7080, "Hyde Park", "🦢")
        case .CentralPark:
            return (9817, "Central Park", "🥯")
        case .LakeGarda:
            return (16700, "Lake Garda", "⛵️")
        case .Manhattan:
            return (21100, "Manhattan", "🍕")
        case .CERN:
            return (27000, "CERN", "🧀")
        }
    }
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
