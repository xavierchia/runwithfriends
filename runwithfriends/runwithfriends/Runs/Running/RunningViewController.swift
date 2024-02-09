//
//  RunningViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 16/11/23.
//

import UIKit
import CoreLocation
import Combine

class RunningViewController: UIViewController {
    
    // initial countdown on top of running
    private let countdownLabel = UILabel()
    
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0
    private var totalTime: TimeInterval = 0
    private let startingTime = Date()
    
    private let runSession: RunSession
    private var cancellables = Set<AnyCancellable>()
    
    private let paceValueLabel = UILabel().topBarTitle()
    private let timeValueLabel = UILabel().topBarTitle()
    private let distanceValueLabel = UILabel()
    private let distanceMetricLabel = UILabel()
    
    init(with runSession: RunSession) {
        self.runSession = runSession
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
        runSession.$runStage.sink { [weak self] runStage in
            guard let self else { return }
            switch runStage {
            case .fiveSecondsToRunStart(let seconds):
                switch seconds {
                case 0:
                    countdownLabel.font = countdownLabel.font.withSize(100)
                    countdownLabel.text = "START"
                default:
                    countdownLabel.text = String(seconds)
                }
            case .runStart(let seconds):
                countdownLabel.removeFromSuperview()
                totalTime = seconds
                
                // update time
                let countupTime = seconds.getMinuteSecondsString(withZeroPadding: true)
                timeValueLabel.text = countupTime
                
//                for testing we move faster
//                totalDistance += 0.5
//                updateDistanceLabel()
//                updatePaceLabel()

            default:
                return
            }
        }.store(in: &cancellables)
    }

    @objc private func endButtonPressed() {
        self.dismiss(animated: true)
    }
    
    @objc private func resultsButtonPressed() {
        let resultsVC = ResultsViewController()
        let resultsNav = UINavigationController(rootViewController: resultsVC)
        resultsNav.modalPresentationStyle = .overFullScreen
        present(resultsNav, animated: true)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    // MARK: Setup UI
    private func setupUI() {
        setupPaceStack()
        setupTimeStack()
        setupDistanceStack()
        setupEndButton()
        setupCountdownView()
    }
    
    private func setupCountdownView() {
        countdownLabel.text = "5"
        countdownLabel.textColor = .cream
        countdownLabel.font = UIFont.chalkboardBold(size: 200)
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
    }
    
    private func setupPaceStack() {
        paceValueLabel.text = "0'00\""
        paceValueLabel.adjustsFontSizeToFitWidth = true
        let paceMetricLabel = UILabel().topBarSubtitle()
        paceMetricLabel.text = "Pace"
        
        let paceStack = UIStackView().verticalStack()
        paceStack.spacing = 5
        paceStack.addArrangedSubview(paceValueLabel)
        paceStack.addArrangedSubview(paceMetricLabel)
        
        view.addSubview(paceStack)
        paceStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paceStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            paceStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            paceStack.widthAnchor.constraint(equalToConstant: 150),
            paceStack.heightAnchor.constraint(equalToConstant: 70)
        ])
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
    
    private func setupDistanceStack() {
        distanceValueLabel.text = "0"
        distanceValueLabel.textColor = .cream
        distanceValueLabel.font = UIFont.chalkboardBold(size: 120)
        distanceValueLabel.textAlignment = .center
        
        distanceMetricLabel.text = "Meters"
        distanceMetricLabel.textColor = .cream
        distanceMetricLabel.font = UIFont.chalkboardBold(size: 17.51)
        distanceMetricLabel.textAlignment = .center
        
        let distanceStack = UIStackView().verticalStack()
        distanceStack.spacing = 10
        distanceStack.addArrangedSubview(distanceValueLabel)
        distanceStack.addArrangedSubview(distanceMetricLabel)
        
        view.addSubview(distanceStack)
        distanceStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            distanceStack.widthAnchor.constraint(equalTo: view.widthAnchor),
            distanceStack.heightAnchor.constraint(equalToConstant: 150),
            distanceStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distanceStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(resultsButtonPressed))
        distanceStack.addGestureRecognizer(tap)
    }
    
    private func setupEndButton() {
        let endButton = UIButton()
        var config = UIImage.SymbolConfiguration(paletteColors: [.accent, .cream])
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)
        config = config.applying(largeConfig)
        let largeStopCircle = UIImage(systemName: "stop.circle.fill", withConfiguration: config)
        endButton.setImage(largeStopCircle, for: .normal)
        
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
    }
}

extension RunningViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last,
              currentLocation.timestamp >= startingTime + 5 else { return }
        
        if let lastLocation {
            totalDistance += currentLocation.distance(from: lastLocation)
            print("location updated \(totalDistance)")
            updateDistanceLabel()
            updatePaceLabel()
        }
        
        self.lastLocation = currentLocation
    }
    
    private func updateDistanceLabel() {
        if totalDistance > 1000 {
            distanceValueLabel.text = String(format: "%.2f", totalDistance / 1000)
            distanceMetricLabel.text = "Kilometers"
        } else {
            distanceValueLabel.text = String(format: "%.0f", totalDistance)
        }
    }
    
    private func updatePaceLabel() {
        guard totalDistance > 0 else { return }
        let pace = totalTime / (totalDistance / 1000)
        var paceString = pace.getMinuteSecondsString()
        paceString = paceString.replacingOccurrences(of: ":", with: "'")
        paceString += "\""
        paceValueLabel.text = paceString
    }
}

// MARK: Helper extensions
private extension UILabel {
    func topBarTitle() -> UILabel {
        self.textColor = .cream
        self.textAlignment = .center
        self.font = UIFont.chalkboardBold(size: 45.84)
        return self
    }
    
    func topBarSubtitle() -> UILabel {
        self.textColor = .cream
        self.font = UIFont.chalkboardBold(size: 17.51)
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
