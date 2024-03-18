//
//  UserDefaults.swift
//  runwithfriends
//
//  Created by xavier chia on 16/3/24.
//

import Foundation

extension UserDefaults {
    enum RunSettings: String {
        case isSetup,
             runAudio,
             runStart,
             runComplete,
             runDistance,
             runTime,
             runFrequency
        
        var label: String {
            switch self {
            case .isSetup:
                return "isSetup"
            case .runAudio:
                return "Running audio"
            case .runStart:
                return "Start"
            case .runComplete:
                return "Complete"
            case .runDistance:
                return "Distance"
            case .runTime:
                return "Time"
            case .runFrequency:
                return "Frequency"
            }
        }
    }
}
