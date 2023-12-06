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
        case oneHourToRunStart(String)
        case fiveSecondsToRunStart(Int)
        case runStart(TimeInterval)
        case runEnd
    }
        
    @Published
    var runStage: RunStage = .waitingRunStart
    var runStartDate: Date
    
    var timer = Timer()
    
    init(runStartDate: Date) {        
        self.runStartDate = runStartDate
        fireTimer()
        setupTimer()
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            fireTimer()
        })
    }
    
    private func fireTimer() {
        let currentDate = Date()
        let intervalToStart = runStartDate.timeIntervalSince(currentDate).rounded()
        switch intervalToStart {
        case 3600...:
            runStage = .waitingRunStart
        case 6...3600:
            let countdownTime = intervalToStart.getMinuteSecondsString()
            runStage = .oneHourToRunStart(countdownTime)
        case 0...5:
            runStage = .fiveSecondsToRunStart(Int(intervalToStart))
        case -1800...0:
            runStage = .runStart(-intervalToStart)
        case ...(-1800):
            runStage = .runEnd
        default:
            break
        }
    }
}
