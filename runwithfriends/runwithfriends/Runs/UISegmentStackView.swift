//
//  RunsSegmentControl.swift
//  runwithfriends
//
//  Created by xavier chia on 5/11/23.
//

import UIKit

protocol UISegmentStackViewProtocol: AnyObject {
    func runsButtonPressed()
    func unlockedButtonPressed()
}

class UISegmentStackView: UIStackView {
    private let runsButton = UIButton()
    private let unlockedButton = UIButton()
    weak var delegate: UISegmentStackViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
        self.distribution = .fillEqually

        runsButton.titleLabel?.textAlignment = .center
        _ = runsButton.titleLabel?.mediumLight()
        unlockedButton.setTitleColor(.white, for: .normal)
        runsButton.setTitle("Upcoming", for: .normal)
        runsButton.addTarget(self, action: #selector(runsButtonPressed), for: .touchUpInside)
        self.addArrangedSubview(runsButton)
        
        unlockedButton.titleLabel?.textAlignment = .center
        _ = unlockedButton.titleLabel?.mediumLight()
        unlockedButton.setTitle("Unlocked", for: .normal)
        unlockedButton.setTitleColor(.gray, for: .normal)
        unlockedButton.addTarget(self, action: #selector(unlockedButtonPressed), for: .touchUpInside)
        self.addArrangedSubview(unlockedButton)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func runsButtonPressed() {
        delegate?.runsButtonPressed()
        
        UIView.transition(with: runsButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.runsButton.setTitleColor(.white, for: .normal)
        }
        UIView.transition(with: unlockedButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.unlockedButton.setTitleColor(.gray, for: .normal)
        }
    }
    
    @objc private func unlockedButtonPressed() {
        delegate?.unlockedButtonPressed()
        
        UIView.transition(with: runsButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.runsButton.setTitleColor(.gray, for: .normal)
        }
        UIView.transition(with: unlockedButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.unlockedButton.setTitleColor(.white, for: .normal)
        }
    }
}
