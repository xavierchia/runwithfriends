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
    
        setupDistanceStack()
        setupEndButton()
    }

    @objc private func tapFunction() {
        print("tapped")
        self.dismiss(animated: true)
    }
    
    
    // MARK: Setup UI
    private func setupDistanceStack() {
        let distanceValueLabel = UILabel()
        distanceValueLabel.text = "2.10"
        distanceValueLabel.textColor = .black
        distanceValueLabel.font = UIFont.systemFont(ofSize: 120).boldItalic
        distanceValueLabel.textAlignment = .center
        
        let distanceMetricLabel = UILabel()
        distanceMetricLabel.text = "Kilometers"
        distanceMetricLabel.textColor = .black
        distanceMetricLabel.font = UIFont.systemFont(ofSize: 18.31, weight: .bold)
        distanceMetricLabel.textAlignment = .center
        
        let distanceStack = UIStackView()
        distanceStack.axis = .vertical
        distanceStack.distribution = .fillProportionally
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        endButton.addGestureRecognizer(tap)
    }
}
