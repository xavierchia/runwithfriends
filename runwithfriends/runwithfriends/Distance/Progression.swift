//
//  distanceReport.swift
//  runwithfriends
//
//  Created by Xavier Chia on 23/2/24.
//

import Foundation
import UIKit
import SharedCode

struct Progression {
    
    struct ProgressData {
        let progress: Float
        let nextMilestone: Milestone
    }
    
    static func getProgressData(for distance: Int) -> ProgressData {
        var distanceTableRows = getDistanceTableRows(for: distance)
        
        let nextMilestone = distanceTableRows.removeFirst()
        let milestoneDistanceSoFar = distanceTableRows.reduce(0) {$0 + $1.info.distance}
        let nextMilestoneCovered = distance - milestoneDistanceSoFar
        let progress = Float(nextMilestoneCovered) / Float(nextMilestone.info.distance)
        return ProgressData(progress: progress, nextMilestone: nextMilestone)
    }
    
    static func getDistanceTableRows(for distance: Int) -> [Milestone] {
        var milestoneTable = [Milestone]()
        var currentDistance = distance
        
        for milestone in Milestone.allCases {
            if milestone.info.distance <= currentDistance {
                milestoneTable.append(milestone)
                currentDistance -= milestone.info.distance
            } else {
                milestoneTable.append(milestone)
                break
            }
        }
        
        milestoneTable.sort { lhs, rhs in
            lhs.info.distance > rhs.info.distance
        }
        
        return milestoneTable
    }
}

enum Milestone: CaseIterable {
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
    case EnglishChannel
    case Badwater
    case CinqueTerre
    case JavelinaJundred
    
    var info: (distance: Int, name: String, emoji: String, shortDescription: String) {
        switch self {
        case .CasualPea:
            return (0, "Casual Pea", "🫛", "")
        case .EiffelTower:
            return (471, "Eiffel Tower Height", "🗼", "the Eiffel Tower in Paris")
        case .BrooklynBridge:
            return (2620, "Brooklyn Bridge", "🛤️", "the Brooklyn Bridge in New York City")
        case .GoldenGateBridge:
            return (3910, "Golden Gate Bridge", "🌉", "the Golden Gate Bridge in San Francisco")
        case .MountFuji:
            return (5394, "Mount Fuji Height", "🗻", "Mount Fuji in Japan")
        case .HydePark:
            return (10114, "Hyde Park", "🦢", "around Hyde Park in London")
        case .CentralPark:
            return (14024, "Central Park", "🥯", "Central Park in New York City")
        case .LakeGarda:
            return (23857, "Lake Garda", "⛵️", "Lake Garda in Italy")
        case .Manhattan:
            return (30143, "Manhattan", "🍕", "Manhattan in New York City")
        case .CERN:
            return (38571, "CERN", "🧀", "CERN in Switzerland")
        case .EnglishChannel:
            return (48571, "English Channel", "🫖", "the English Channel")
        case .Badwater:
            return (71429, "Badwater Capefear", "🧨", "Badwater Capefear in North Carolina")
        case .CinqueTerre:
            return (92857, "Cinque Terre", "🏖️", "the Cinque Terra coast in Italy")
        case .JavelinaJundred:
            return (142857, "Javelina Jundred", "💯", "Javelina Jundred in Arizona")
        }
    }
}
