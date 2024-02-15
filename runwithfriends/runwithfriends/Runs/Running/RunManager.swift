//
//  LocationManager.swift
//  runwithfriends
//
//  Created by xavier chia on 30/11/23.
//

import Foundation
import Combine
import CoreLocation

class RunManager {
    
    enum RunStage {
        case waitingRunStart
        case oneHourToRunStart(String)
        case fiveSecondsToRunStart(Int)
        case runStart(TimeInterval)
        case runEnd
    }
        
    @Published
    public var runStage: RunStage = .waitingRunStart
    public var run: Run
    
    private let supabase = Supabase.shared.client.database
    private var timer = Timer()
    
    init(with run: Run) {
        self.run = run
        fireTimer()
        setupTimer()
    }
    
    public func upsertRun(with user: User, and distance: Int = 0) {
        Task {
            do {
                let session = RunSession(run_id: run.run_id, user_id: user.user_id, distance: distance)
                try await supabase
                    .from("run_session")
                    .upsert(session)
                    .execute()
                print("User upserted to run session")
            } catch {
                print("Unable to upsert run session \(error)")
            }

        }
    }
    
    public func leaveRun(with user: User) {
        Task {
            do {
                try await supabase.from("run_session")
                    .delete()
                    .eq("run_id", value: run.run_id)
                    .eq("user_id", value: user.user_id)
                    .execute()
                print("User removed from run session")
            } catch {
                print("Unable to delete run session \(error)")
            }
        }
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
