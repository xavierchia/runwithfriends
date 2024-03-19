//
//  distanceReport.swift
//  runwithfriends
//
//  Created by Xavier Chia on 23/2/24.
//

import Foundation
import UIKit

struct Progression {
    
    struct ProgressData {
        let progress: Float
        let distanceLeft: Int
        let currentLandmark: Milestone
        let nextLandmark: Milestone
    }
    
    static func getProgressData(for distance: Int) -> ProgressData {
        let distanceTableRows = getLandmarkTable(for: distance)
        
        let nextLandmark = distanceTableRows.first!
        let currentLandmark = distanceTableRows[safe: 1] ?? Pea.CasualPea
        
        let landmarkDifference = nextLandmark.info.distance - currentLandmark.info.distance
        let differenceCovered = distance - currentLandmark.info.distance
        let distanceLeft = nextLandmark.info.distance - distance
        let progressPercentage = Float(differenceCovered) / Float(landmarkDifference)
        
        return ProgressData(progress: progressPercentage, distanceLeft: distanceLeft, currentLandmark: currentLandmark, nextLandmark: nextLandmark)
    }
    
    static private func getLandmarkTable(for distance: Int) -> [Milestone] {
        var landmarkTable = [Milestone]()
        
        for landmark in Landmark.allCases {
            if landmark.info.distance <= distance {
                landmarkTable.append(landmark)
            } else {
                landmarkTable.append(landmark)
                break
            }
        }
        
        landmarkTable.sort { lhs, rhs in
            lhs.info.distance > rhs.info.distance
        }
        
        return landmarkTable
    }
    
    // Includes Peas and Milestones
    static func getDistanceTableRows(for distance: Int) -> [Milestone] {
        var distanceTableRows = [Milestone]()
        
        for landmark in Landmark.allCases {
            if landmark.info.distance <= distance {
                distanceTableRows.append(landmark)
            } else {
                distanceTableRows.append(landmark)
                break
            }
        }
        
        for pea in Pea.allCases {
            if pea.info.distance <= distance {
                distanceTableRows.append(pea)
            }
        }
        
        distanceTableRows.sort { lhs, rhs in
            lhs.info.distance > rhs.info.distance
        }
        
        return distanceTableRows
    }
    
    static func getPea(for distance: Int) -> Pea {
        var currentPea = Pea.CasualPea
        for pea in Pea.allCases {
            if distance >= pea.info.distance {
                currentPea = pea
            }
        }
        
        return currentPea
    }
}

protocol Milestone {
    var info: (distance: Int, name: String, emoji: String, shortDescription: String) { get }
}

enum Pea: CaseIterable, Milestone {
    case CasualPea
    case ProgressivePea
    
    var info: (distance: Int, name: String, emoji: String, shortDescription: String) {
        switch self {
        case .CasualPea:
            return (0, "Casual Pea", "🫛", "")
        case .ProgressivePea:
            return (5000, "Progressive Pea", "🫛", "")
        }
    }
}

enum Landmark: CaseIterable, Milestone {
    case EiffelTower
    case BrooklynBridge
    case GoldenGateBridge
    case MountFuji
    case HydePark
    case CentralPark
    case LakeGarda
    case Manhattan
    case CERN
    case EnglishChannel
    case NYCMarathon
    case Badwater
    case CinqueTerre
    case JavelinaJundred
    
    var info: (distance: Int, name: String, emoji: String, shortDescription: String) {
        switch self {
        case .EiffelTower:
            return (330, "Eiffel Tower", "🗼", "the Eiffel Tower in Paris")
        case .BrooklynBridge:
            return (1834, "Brooklyn Bridge", "🛤️", "the Brooklyn Bridge in New York City")
        case .GoldenGateBridge:
            return (2737, "Golden Gate Bridge", "🌉", "the Golden Gate Bridge in San Francisco")
        case .MountFuji:
            return (3776, "Mount Fuji", "🗻", "Mount Fuji in Japan")
        case .HydePark:
            return (7080, "Hyde Park", "🦢", "around Hyde Park in London")
        case .CentralPark:
            return (9817, "Central Park", "🥯", "Central Park in New York City")
        case .LakeGarda:
            return (16700, "Lake Garda", "⛵️", "Lake Garda in Italy")
        case .Manhattan:
            return (21100, "Manhattan", "🍕", "Manhattan in New York City")
        case .CERN:
            return (27000, "CERN", "🧀", "CERN in Switzerland")
        case .EnglishChannel:
            return (34000, "English Channel", "🫖", "the English Channel")
        case .NYCMarathon:
            return (42000, "New York City Marathon", "🗽", "the New York City Marathon")
        case .Badwater:
            return (50000, "Badwater Capefear", "🗽", "Badwater Capefear in North Carolina")
        case .CinqueTerre:
            return (65000, "Cinque Terre", "🗽", "the Cinque Terra coast in Italy")
        case .JavelinaJundred:
            return (100000, "Javelina Jundred", "🗽", "Javelina Jundred in Arizona")
        }
    }
}
