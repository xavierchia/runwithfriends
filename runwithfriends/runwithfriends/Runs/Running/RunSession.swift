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
    var run: Run
    
    var timer = Timer()
    
    init(with run: Run) {
        self.run = run
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
        let intervalToStart = run.start_date.getDate().timeIntervalSince(currentDate).rounded()
        switch intervalToStart {
        case 3600...:
            runStage = .waitingRunStart
        case 6...3600:
            let countdownTime = intervalToStart.positionalTime
            runStage = .oneHourToRunStart(countdownTime)
        case 0...5:
            runStage = .fiveSecondsToRunStart(Int(intervalToStart))
        // Each run is 25 minutes
        case -1500...0:
            runStage = .runStart(-intervalToStart)
        case ...(-1500):
            runStage = .runEnd
        default:
            break
        }
    }
}
