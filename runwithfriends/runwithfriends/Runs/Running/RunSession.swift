//
//  LocationManager.swift
//  runwithfriends
//
//  Created by xavier chia on 30/11/23.
//

import Foundation
import Combine
import CoreLocation

class RunSession {
    
    enum RunStage {
        case waitingRunStart
        case threeSecondsToRunStart
        case runStart(String)
        case runEnd
    }
        
    @PostPublished
    var runStage: RunStage = .waitingRunStart
    var runStartDate: Date
    
    init(runStartdate: Date) {
        self.runStartDate = runStartdate
    }
}
