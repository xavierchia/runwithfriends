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
                                nextAchievement: "Completing the Golden Gate Bridge in San Francisco.")
            return report
        case ..<Landmarks.MountFuji:
            let distanceLeft = Landmarks.MountFuji - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the Golden Gate Bridge in San Francisco!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing Mount Fuji in Japan.")
            return report
        case ..<Landmarks.HydePark:
            let distanceLeft = Landmarks.HydePark - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the height of Mount Fuji in Japan!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the Hyde Park big loop in London.")
            return report
        case ..<Landmarks.CentralPark:
            let distanceLeft = Landmarks.CentralPark - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the Hyde Park big loop in London!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the Central Park big loop in New York!")
            return report
        case ..<Landmarks.LakeGarda:
            let distanceLeft = Landmarks.LakeGarda - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the Central Park big loop in New York!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the width of Lake Garda in Italy.")
            return report
        case ..<Landmarks.Manhattan:
            let distanceLeft = Landmarks.Manhattan - distance
            let nextDistance = getColoredString(with: .nextDistance, and: distanceLeft)
            let report = Report(currentDistance: currentDistance,
                                currentAchievement: "That's more than the width of Lake Garda in Italy!",
                                nextDistance: nextDistance,
                                nextAchievement: "Completing the length of Manhattan in New York!")
            return report
        case ..<Landmarks.CERN:
            let distanceLeft = Landmarks.CERN - distance
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

struct Landmarks {
    static let EiffelTower = 330
    static let HighLineNewYork = 2300
    static let GoldenGateBridge = 2737
    static let MountFuji = 3776
    static let HydePark = 7080
    static let CentralPark = 9817
    static let LakeGarda = 16700
    static let Manhattan = 21100
    static let CERN = 27000
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
