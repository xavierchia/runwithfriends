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
    
    enum RunStage: Comparable {
        case waitingRunStart
        case oneHourToRunStart(String)
        case fiveSecondsToRunStart(Int)
        case runStart(TimeInterval)
        case runEnd
    }
        
    @Published
    public var runStage: RunStage = .waitingRunStart
    public var run: Run
    public let user: User

    private let supabase = Supabase.shared.client.database
    private var timer = Timer()
    private var lastUpdateInterval: TimeInterval = 100_000
    
    init(with run: Run, and user: User) {
        self.run = run
        self.user = user
        fireTimer()
        setupTimer()
    }
    
    public func syncRun() async {
        do {
            let runs: [Run] = try await supabase
              .rpc("get_run", params: ["get_run_id": self.run.run_id])
              .select()
              .execute()
              .value
            if let run = runs.first {
                print("run synced")
                self.run = run
            }
        } catch {
            print(error)
        }
    }
    
    public func upsertRun(with distance: Int = 0) async {
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
    
    public func leaveRun() {
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
        let intervalToStart = run.start_date.getDate().timeIntervalSince(Date()).rounded()
        var runTime = Double(run.end_date - run.start_date)
        // for testing
//        runTime = 100
        
        switch intervalToStart {
        case 3600...:
            runStage = .waitingRunStart
        case 6...3600:
            let countdownTime = intervalToStart.positionalTime
            runStage = .oneHourToRunStart(countdownTime)
        case 0...6:
            runStage = .fiveSecondsToRunStart(Int(intervalToStart))
        case -runTime...0:
            // We only publish on whole seconds once the run has started
            // so we don't overload the server with updates.
            // Before the run has started, we publish frequently every second to get the labels updated quickly.
            guard lastUpdateInterval != intervalToStart else { return }
            lastUpdateInterval = intervalToStart
            
            runStage = .runStart(-intervalToStart)
        case ...(-runTime):
            runStage = .runEnd
            timer.invalidate()
        default:
            break
        }
    }
}
