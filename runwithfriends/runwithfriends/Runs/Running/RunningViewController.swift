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
    
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    var totalDistance: CLLocationDistance = 0
    let startingTime = Date()
    var timer = Timer()
    
    let distanceValueLabel = UILabel()
    let timeValueLabel = UILabel().topBarTitle()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .accent
        setupLocationManager()
        setupUI()
        startTimer()
        
    }
        
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [ weak self ] timer in
            guard let self else { return }
            let calendar = Calendar.current
            let components = calendar.dateComponents([.minute, .second], from: startingTime, to: Date())
            guard let minuteInt = components.minute,
                  let secondInt = components.second else { return }
            let minuteString = String(format: "%02d", minuteInt)
            let secondString = String(format: "%02d", secondInt)
            let timeString = "\(minuteString):\(secondString)"
            timeValueLabel.text = timeString
        })
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
        
        let distanceMetricLabel = UILabel()
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
        if let lastLocation {
            totalDistance += currentLocation.distance(from: lastLocation)
            print(totalDistance)
            distanceValueLabel.text = String(format: "%.0f", totalDistance)
        }
        
        self.lastLocation = currentLocation
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
