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
    public var sessionDistance: CLLocationDistance = 0
    public var run: Run
    public let userData: UserData
    
    private let supabase = Supabase.shared.client.database
    private var timer = Timer()
    private var isAudioCountdownStarted = false
    private var lastUpdateInterval: TimeInterval = 100_000
    private var lastProgress: Float = 0
    private var soloRunCreated = false
        
    init(with run: Run, and userData: UserData) {
        self.run = run
        self.userData = userData
        fireTimer()
        setupTimer()
    }
    
    deinit {
        print("deinit run manager")
        timer.invalidate()
    }
    
    public func getTotalDistance() -> Int {
        let previousDistances = userData.getTotalDistance()
        return previousDistances + Int(sessionDistance)
    }
    
    public static func createRun(with run: Run_Raw) async {
        #if DEBUG
        return
        #else
        do {
            try await Supabase.shared.client.database
                .from("runs")
                .upsert(run)
                .execute()
            print("User created run")
        } catch {
            print("Unable to create run \(error)")
        }
        #endif
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
    
    public func upsertRunSession(with distance: Int = 0) async {
        #if DEBUG
        return
        #else
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
        #endif
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
//            self.sessionDistance += 20
        })
    }
    
    private func fireTimer() {
        let intervalToStart = run.start_date.getDate().timeIntervalSince(Date()).rounded()
        var runTime = Double(run.end_date - run.start_date)
        // for testing
//        runTime = 10
        
        switch intervalToStart {
        case 3600...:
            runStage = .waitingRunStart
        case 6...3600:
            let countdownTime = intervalToStart.positionalTime
            runStage = .oneHourToRunStart(countdownTime)
        case 0...6:
            runStage = .fiveSecondsToRunStart(Int(intervalToStart))
            
            if isAudioCountdownStarted == false {
                isAudioCountdownStarted = true
                let utterance = AVSpeechUtterance(string: "Five... Four... Three... Two... One... Start...")
                utterance.rate = 0.1
                Speaker.shared.speak(utterance)
            }

        case -runTime...0:
            
            if run.type == .solo && soloRunCreated == false {
                soloRunCreated = true
                Task {
                    await RunManager.createRun(with: run.toRunRaw())
                }
            }
            
            let progressData = Progression.getProgressData(for: getTotalDistance())
            let currentLandmarkShortDescription = progressData.currentLandmark.info.shortDescription
            let nextLandmarkShortDescription = progressData.nextLandmark.info.shortDescription
            
            // We only publish on whole seconds once the run has started
            // so we don't overload the server with updates.
            // Before the run has started, we publish frequently every second to get the labels updated quickly.
            guard lastUpdateInterval != intervalToStart else { return }
            lastUpdateInterval = intervalToStart
            let secondsPassed = -intervalToStart
            runStage = .runStart(secondsPassed)
            switch secondsPassed {
            case 10:
                let utterance = AVSpeechUtterance(string: "Your next milestone is \(nextLandmarkShortDescription)")
                utterance.rate = 0.3
                Speaker.shared.speak(utterance)
            case 60, 300, 600:
                let minutes = Int(secondsPassed) / 60
                let totalDistance = sessionDistance
                let utterance = AVSpeechUtterance(string: "Time \(minutes) minutes, distance \(Int(totalDistance).value) \(Int(totalDistance).metric)")
                utterance.rate = 0.3
                Speaker.shared.speak(utterance)
            default:
                break
            }
            
            if progressData.progress < lastProgress {
                let utterance = AVSpeechUtterance(string: "You have finished \(currentLandmarkShortDescription), your next milestone is \(nextLandmarkShortDescription)")
                utterance.rate = 0.3
                Speaker.shared.speak(utterance)
            }
            lastProgress = progressData.progress

        case ...(-runTime):
            runStage = .runEnd
            let runCompleteString = run.type == .solo ? "Run complete." : "Run complete. Getting results."
            let utterance = AVSpeechUtterance(string: runCompleteString)
            utterance.rate = 0.3
            Speaker.shared.speak(utterance)
            timer.invalidate()
        default:
            break
        }
    }
}
