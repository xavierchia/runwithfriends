//
//  RunningViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 16/11/23.
//

import UIKit

class RunningViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .accent
    
        setupPaceStack()
        setupTimeStack()
        setupDistanceStack()
        setupEndButton()
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
    
    
    // MARK: Setup UI
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
            paceStack.widthAnchor.constraint(equalToConstant: 140),
            paceStack.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupTimeStack() {
        let timeValueLabel = UILabel().topBarTitle()
        timeValueLabel.text = "13:40"
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
            timeStack.widthAnchor.constraint(equalToConstant: 125),
            timeStack.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupDistanceStack() {
        let distanceValueLabel = UILabel()
        distanceValueLabel.text = "2.10"
        distanceValueLabel.textColor = .black
        distanceValueLabel.font = UIFont.systemFont(ofSize: 120).boldItalic
        distanceValueLabel.textAlignment = .center
        
        let distanceMetricLabel = UILabel()
        distanceMetricLabel.text = "Kilometers"
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
