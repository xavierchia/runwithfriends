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
    private let startingTime = Date()
    private var timer = Timer()
    
    private let runSession: RunSession
    private var cancellables = Set<AnyCancellable>()
    
    private let distanceValueLabel = UILabel()
    private let distanceMetricLabel = UILabel()
    private let timeValueLabel = UILabel().topBarTitle()
    
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
            case .runStart(let countupTime):
                countdownLabel.removeFromSuperview()
                timeValueLabel.text = countupTime
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
        countdownLabel.textColor = .black
        countdownLabel.font = UIFont.systemFont(ofSize: 200).boldItalic
        countdownLabel.textAlignment = .center
        countdownLabel.backgroundColor = .systemOrange
        
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
        let paceValueLabel = UILabel().topBarTitle()
        paceValueLabel.text = "7'10\""
        let paceMetricLabel = UILabel().topBarSubtitle()
        paceMetricLabel.text = "Pace"
        
        let paceStack = UIStackView().verticalStack()
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
        distanceValueLabel.textColor = .black
        distanceValueLabel.font = UIFont.systemFont(ofSize: 120).boldItalic
        distanceValueLabel.textAlignment = .center
        
        distanceMetricLabel.text = "Meters"
        distanceMetricLabel.textColor = .black
        distanceMetricLabel.font = UIFont.systemFont(ofSize: 17.51, weight: .bold)
        distanceMetricLabel.textAlignment = .center
        
        let distanceStack = UIStackView().verticalStack()
        distanceStack.addArrangedSubview(distanceValueLabel)
        distanceStack.addArrangedSubview(distanceMetricLabel)
        
        view.addSubview(distanceStack)
        distanceStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            distanceStack.widthAnchor.constraint(equalTo: view.widthAnchor),
            distanceStack.heightAnchor.constraint(equalToConstant: 130),
            distanceStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distanceStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(resultsButtonPressed))
        distanceStack.addGestureRecognizer(tap)
    }
    
    private func setupEndButton() {
        let endButton = UIButton()
        var config = UIImage.SymbolConfiguration(paletteColors: [.white, .black])
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
        
        // for testing
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.totalDistance += 50
            self.updateDistanceLabel()
        }
        
        if let lastLocation {
            totalDistance += currentLocation.distance(from: lastLocation)
            updateDistanceLabel()
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
}

// MARK: Helper extensions
private extension UILabel {
    func topBarTitle() -> UILabel {
        self.textColor = .black
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 45.84, weight: .bold)
        return self
    }
    
    func topBarSubtitle() -> UILabel {
        self.textColor = .black
        self.font = UIFont.systemFont(ofSize: 17.51, weight: .bold)
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
