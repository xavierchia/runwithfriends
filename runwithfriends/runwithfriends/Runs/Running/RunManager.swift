//
//  LocationManager.swift
//  runwithfriends
//
//  Created by xavier chia on 30/11/23.
//

import Foundation
import Combine
import CoreLocation
import AVFoundation

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
    
    @Published
    public var totalDistance: CLLocationDistance = 0
    public var run: Run
    public let userData: UserData
    
    private let supabase = Supabase.shared.client.database
    private var timer = Timer()
    private var lastUpdateInterval: TimeInterval = 100_000
    private var countdownStarted = false
    
    init(with run: Run, and userData: UserData) {
        self.run = run
        self.userData = userData
        fireTimer()
        setupTimer()
    }
    
    deinit {
        timer.invalidate()
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
            let session = RunSession(run_id: run.run_id, user_id: userData.user.user_id, distance: distance)
            try await supabase
                .from("run_session")
                .upsert(session)
                .execute()
            print("User upserted to run session with distance \(distance)")
        } catch {
            print("Unable to upsert run session \(error)")
        }
    }
    
    public func leaveRun() async {
        do {
            try await supabase.from("run_session")
                .delete()
                .eq("run_id", value: run.run_id)
                .eq("user_id", value: userData.user.user_id)
                .execute()
            print("User removed from run session")
        } catch {
            print("Unable to delete run session \(error)")
        }
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            fireTimer()
            
            // for testing we move faster
//            self.totalDistance += 0.5
        })
    }
    
    private func fireTimer() {
        let intervalToStart = run.start_date.getDate().timeIntervalSince(Date()).rounded()
        var runTime = Double(run.end_date - run.start_date)
        // for testing
        runTime = 10
        
        switch intervalToStart {
        case 3600...:
            runStage = .waitingRunStart
        case 6...3600:
            let countdownTime = intervalToStart.positionalTime
            runStage = .oneHourToRunStart(countdownTime)
        case 0...6:
            if countdownStarted == false {
                countdownStarted = true
                let utterance = AVSpeechUtterance(string: "Five... Four... Three... Two... One... Start...")
                utterance.rate = 0.1
                Speaker.shared.speak(utterance)
            }
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
            let utterance = AVSpeechUtterance(string: "Run complete. Getting results.")
            utterance.rate = 0.3
            Speaker.shared.speak(utterance)
            timer.invalidate()
        default:
            break
        }
    }
}
