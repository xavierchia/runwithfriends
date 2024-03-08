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
        let nextLandmark: Milestone
    }
    
    static func getProgressData(for distance: Int) -> ProgressData? {
        var distanceTableRows = [Milestone]()
        
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
        
        guard let nextLandmark = distanceTableRows.first else { return nil }
        let currentLandmark = distanceTableRows[safe: 1] ?? Pea.CasualPea
        
        let landmarkDifference = nextLandmark.info.distance - currentLandmark.info.distance
        let differenceCovered = distance - currentLandmark.info.distance
        let distanceLeft = nextLandmark.info.distance - distance
        let progressPercentage = Float(differenceCovered) / Float(landmarkDifference)
        
        return ProgressData(progress: progressPercentage, distanceLeft: distanceLeft, nextLandmark: nextLandmark)
    }
    
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
    var info: (distance: Int, name: String, emoji: String) { get }
}

enum Pea: CaseIterable, Milestone {
    case CasualPea
    case ProgressivePea
    
    var info: (distance: Int, name: String, emoji: String) {
        switch self {
        case .CasualPea:
            return (0, "Casual Pea", "🫛")
        case .ProgressivePea:
            return (5000, "Progressive Pea", "🫛")
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
    
    var info: (distance: Int, name: String, emoji: String) {
        switch self {
        case .EiffelTower:
            return (330, "Eiffel Tower", "🗼")
        case .BrooklynBridge:
            return (1834, "Brooklyn Bridge", "🛤️")
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
