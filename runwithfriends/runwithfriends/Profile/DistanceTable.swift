//
//  distanceReport.swift
//  runwithfriends
//
//  Created by Xavier Chia on 23/2/24.
//

import Foundation
import UIKit

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
    case CasualPea
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
        case .CasualPea:
            return (0, "Casual Pea", "🫛")
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
