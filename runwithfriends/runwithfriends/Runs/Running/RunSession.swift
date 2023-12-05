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
        let intervalToStart = runStartDate.timeIntervalSince(currentDate).rounded()
        switch intervalToStart {
        case 3600...:
            runStage = .waitingRunStart
        case 6...3600:
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            let countdownTime = formatter.string(from: intervalToStart)!
            runStage = .oneHourToRunStart(countdownTime)
        case 0...5:
            runStage = .fiveSecondsToRunStart(Int(intervalToStart))
        case -1800...0:
            runStage = .runStart
        case ...(-1800):
            runStage = .runEnd
        default:
            break
        }
    }
}
