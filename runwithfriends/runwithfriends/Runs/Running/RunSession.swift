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
        case oneHourToRunStart
        case threeSecondsToRunStart
        case runStart
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
        let calendar = Calendar.current
        let currentDate = Date()
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        let currentSecond = calendar.component(.second, from: currentDate)
        let nextWholeSecond = Calendar.current.date(bySettingHour: currentHour, minute: currentMinute, second: currentSecond + 1, of: currentDate)!
        timer = Timer(fire: nextWholeSecond, interval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            fireTimer()
        })
        
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func fireTimer() {
        let currentDate = Date()
        let intervalToStart = self.runStartDate.timeIntervalSince(currentDate)
        switch intervalToStart {
        case 3600...:
            runStage = .waitingRunStart
        case 4...3600:
            runStage = .oneHourToRunStart
        case 0...4:
            runStage = .threeSecondsToRunStart
        case -1800...0:
            runStage = .runStart
        case ...(-1800):
            runStage = .runEnd
        default:
            break
        }
    }
}
