//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit

class RunsViewController: UIViewController {
    
    let runsButton = UIButton()
    let unlockedButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "5K Runs"
        // Do any additional setup after loading the view.
        
        // Initialize
        let segmentStackView = UIStackView()
        segmentStackView.axis = .horizontal
        segmentStackView.distribution = .fillEqually
        view.addSubview(segmentStackView)
        
        runsButton.titleLabel?.textAlignment = .center
        _ = runsButton.titleLabel?.mediumLight().white()
        runsButton.setTitle("Upcoming", for: .normal)
        runsButton.addTarget(self, action: #selector(runsButtonPressed), for: .touchUpInside)
        segmentStackView.addArrangedSubview(runsButton)
        
        unlockedButton.titleLabel?.textAlignment = .center
        _ = unlockedButton.titleLabel?.mediumLight().gray()
        unlockedButton.setTitle("Unlocked", for: .normal)
        unlockedButton.setTitleColor(.gray, for: .normal)
        unlockedButton.addTarget(self, action: #selector(unlockedButtonPressed), for: .touchUpInside)
        segmentStackView.addArrangedSubview(unlockedButton)

        segmentStackView.translatesAutoresizingMaskIntoConstraints = false
        let leftMargin = navigationController!.systemMinimumLayoutMargins.leading
        let rightMargin = navigationController!.systemMinimumLayoutMargins.trailing

        NSLayoutConstraint.activate([
            segmentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftMargin),
            segmentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -rightMargin),
            segmentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentStackView.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
    
    @objc private func runsButtonPressed() {
        UIView.transition(with: runsButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.runsButton.setTitleColor(.white, for: .normal)
        }
        UIView.transition(with: unlockedButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.unlockedButton.setTitleColor(.gray, for: .normal)
        }
        
        print("runs button pressed")
    }
    
    @objc private func unlockedButtonPressed() {
        print("runs button pressed")
        UIView.transition(with: runsButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.runsButton.setTitleColor(.gray, for: .normal)
        }
        UIView.transition(with: unlockedButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.unlockedButton.setTitleColor(.white, for: .normal)
        }
    }
}
