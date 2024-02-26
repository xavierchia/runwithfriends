//
//  RunningViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 16/11/23.
//

import UIKit
import CoreLocation
import Combine
import AVFoundation

class RunningViewController: UIViewController {
    
    // initial countdown on top of running
    private let countdownLabel = UILabel()
    
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0
    private var totalTime: TimeInterval = 0
    private let startingTime = Date()
    
    private let runManager: RunManager
    private var cancellables = Set<AnyCancellable>()
    
    private let distanceValueLabel = UILabel().topBarTitle()
    private let distanceMetricLabel = UILabel().topBarSubtitle()
    private let timeValueLabel = UILabel().topBarTitle()
    
    private let likeNameLabel = UILabel().midSubtitle()
    
    private var touchCountTimer: Timer?
    private let endButton = UIButton(type: .custom)
    
    init(with runManager: RunManager) {
        self.runManager = runManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .accent
        setupLocationManager()
        setupUI()
        respondToRunStage()
    }
    
    private func respondToRunStage() {
        runManager.$runStage.sink { [weak self] runStage in
            guard let self else { return }
            switch runStage {
            case .fiveSecondsToRunStart(let seconds):
                switch seconds {
                case 0:
                    countdownLabel.font = countdownLabel.font.withSize(80)
                    countdownLabel.text = "START"
                default:
                    countdownLabel.text = String(seconds)
                }
            case .runStart(let seconds):
                countdownLabel.removeFromSuperview()
                totalTime = seconds
                
                // for testing we move faster
                totalDistance += 0.5
                
                updateLabels()
                updateAudio()
                updateServer()
            case .runEnd:
                resultsButtonPressed()
            default:
                break
            }
        }.store(in: &cancellables)
    }
    
    @objc private func resultsButtonPressed() {
        Task {
            // Upsert when run is complete
            await runManager.upsertRun(with: Int(totalDistance))
            let resultsVC = ResultsViewController(with: runManager)
            let resultsNav = UINavigationController(rootViewController: resultsVC)
            resultsNav.modalPresentationStyle = .overFullScreen
            present(resultsNav, animated: true)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    // MARK: Setup UI
    private func setupUI() {
        setupDistanceStack()
        setupTimeStack()
        setupLikeStack()
        setupEndButton()
        setupCountdownView()
    }
    
    private func setupCountdownView() {
        countdownLabel.text = "5"
        countdownLabel.textColor = .cream
        countdownLabel.font = UIFont.KefirBold(size: 200)
        countdownLabel.textAlignment = .center
        countdownLabel.backgroundColor = .accent
        
        view.addSubview(countdownLabel)
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countdownLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            countdownLabel.heightAnchor.constraint(equalTo: view.heightAnchor),
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // for testing
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeCountdownLabel))
        countdownLabel.isUserInteractionEnabled = true
        countdownLabel.addGestureRecognizer(tap)
    }
    
    @objc private func removeCountdownLabel() {
        print("remove me")
        countdownLabel.removeFromSuperview()
    }
    
    private func setupDistanceStack() {
        distanceValueLabel.text = "0"
        distanceMetricLabel.text = "Meters"
        
        let distanceStack = UIStackView().verticalStack()
        distanceStack.spacing = 5
        distanceStack.addArrangedSubview(distanceValueLabel)
        distanceStack.addArrangedSubview(distanceMetricLabel)
        
        view.addSubview(distanceStack)
        distanceStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            distanceStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            distanceStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            distanceStack.widthAnchor.constraint(equalToConstant: 150),
            distanceStack.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // for testing
        let tap = UITapGestureRecognizer(target: self, action: #selector(resultsButtonPressed))
        distanceStack.addGestureRecognizer(tap)
    }
    
    private func setupTimeStack() {
        timeValueLabel.text = "00:00"
        let timeMetricLabel = UILabel().topBarSubtitle()
        timeMetricLabel.text = "Time"
        
        let timeStack = UIStackView().verticalStack()
        timeStack.spacing = 5
        timeStack.addArrangedSubview(timeValueLabel)
        timeStack.addArrangedSubview(timeMetricLabel)
        
        view.addSubview(timeStack)
        timeStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            timeStack.widthAnchor.constraint(equalToConstant: 150),
            timeStack.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    
    private func setupLikeStack() {
        let likeButton = UIButton()
        var config = UIImage.SymbolConfiguration(paletteColors: [.pumpkin, .cream])
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)
        config = config.applying(largeConfig)
        let heartCircleFill = UIImage(systemName: "heart.circle.fill", withConfiguration: config)
        likeButton.setImage(heartCircleFill, for: .normal)
        
        view.addSubview(likeButton)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeButton.widthAnchor.constraint(equalToConstant: 150),
            likeButton.heightAnchor.constraint(equalToConstant: 150),
            likeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        likeNameLabel.text = "Xavier"
        
        view.addSubview(likeNameLabel)
        likeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeNameLabel.widthAnchor.constraint(equalToConstant: 150),
            likeNameLabel.heightAnchor.constraint(equalToConstant: 30),
            likeNameLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 5),
            likeNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // change this to a text rounded button just like the invite button
    private func setupEndButton() {
        var config = UIImage.SymbolConfiguration(paletteColors: [.cream, .cream])
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .regular, scale: .large)
        config = config.applying(largeConfig)
        let largeStopCircle = UIImage(systemName: "stop.circle", withConfiguration: config)
        endButton.setImage(largeStopCircle, for: .normal)
        endButton.setImage(largeStopCircle, for: .highlighted)
        
        view.addSubview(endButton)
        endButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            endButton.widthAnchor.constraint(equalToConstant: 100),
            endButton.heightAnchor.constraint(equalToConstant: 100),
            endButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endButtonPressed))
        endButton.addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(endButtonLongPressed))
        longPress.minimumPressDuration = 0.1
        endButton.addGestureRecognizer(longPress)
    }
    
    @objc private func endButtonPressed() {
        print("tapping")
        showToast(message: "Long press to cancel run")
    }
    
    @objc private func endButtonLongPressed(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            print("began long press to cancel run")
                        
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
                self.endButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }
            
            touchCountTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                guard let self else { return }
                
                print("cancelling run")
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.touchCountTimer?.invalidate()
                self.view.window?.rootViewController?.dismiss(animated: true)
                self.view.window?.rootViewController?.showToast(message: "Run cancelled", heightFromBottom: 170)

                Task {
                    if self.totalDistance > 0 {
                        await self.runManager.upsertRun(with: Int(self.totalDistance))
                        await self.runManager.userData.syncUserSessions()
                    } else {
                        await self.runManager.leaveRun()
                    }
                }
            }
        default:
            UIView.animate(withDuration: 0.6) {
                self.endButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            endButtonPressed()
            touchCountTimer?.invalidate()
        }
    }
}

// MARK: Update location, labels, audio
extension RunningViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last,
              currentLocation.timestamp >= startingTime + 5 else { return }
        
        if let lastLocation {
            totalDistance += currentLocation.distance(from: lastLocation)
            print("location updated \(totalDistance)")
            updateLabels()
        }
        
        self.lastLocation = currentLocation
    }
    
    private func updateLabels() {
        // distance
        distanceValueLabel.text = Int(totalDistance).value
        distanceMetricLabel.text = Int(totalDistance).metric
        
        // time
        timeValueLabel.text = totalTime.positionalTime
    }
    
    private func updateAudio() {
        switch Int(totalTime) {
        case 60, 300, 600:
            guard !Speaker.shared.isSpeaking else { return }
            let minutes = Int(totalTime) / 60
            let utterance = AVSpeechUtterance(string: "Time \(minutes) minutes, distance \(Int(totalDistance).value) \(Int(totalDistance).metric)")
            utterance.rate = 0.1
            Speaker.shared.speak(utterance)
        default:
            break
        }
    }
}

// MARK: Update server
extension RunningViewController {
    func updateServer() {
        switch totalTime {
        case 60, 300, 600:
            Task {
                // Upsert during run interval
                await runManager.upsertRun(with: Int(totalDistance))
            }
            
        default:
            break
        }
    }
}

// MARK: Helper extensions
private extension UILabel {
    func topBarTitle() -> UILabel {
        self.textColor = .cream
        self.textAlignment = .center
        self.font = UIFont.KefirBold(size: 45.84)
        return self
    }
    
    func topBarSubtitle() -> UILabel {
        self.textColor = .cream
        self.font = UIFont.KefirBold(size: 17.51)
        self.textAlignment = .center
        return self
    }
    
    func midSubtitle() -> UILabel {
        self.textColor = .cream
        self.font = UIFont.KefirBold(size: 28.33)
        self.textAlignment = .center
        return self
    }
}

private extension UIStackView {
    func verticalStack() -> UIStackView {
        self.axis = .vertical
        self.distribution = .fillProportionally
        return self
    }
}
