//
//  RunsSegmentControl.swift
//  runwithfriends
//
//  Created by xavier chia on 5/11/23.
//

import UIKit

protocol UISegmentStackViewProtocol: AnyObject {
    func segmentLeftButtonPressed()
    func segmentRightButtonPressed()
}

class UISegmentStackView: UIStackView {
    private let runsButton = UIButton()
    private let unlockedButton = UIButton()
    weak var delegate: UISegmentStackViewProtocol?
    
    init(leftTitle: String, rightTitle: String) {
        super.init(frame: .zero)
        self.axis = .horizontal
        self.distribution = .fillEqually

        runsButton.titleLabel?.textAlignment = .center
        _ = runsButton.titleLabel?.mediumBold()
        unlockedButton.setTitleColor(.white, for: .normal)
        runsButton.setTitle(leftTitle, for: .normal)
        runsButton.addTarget(self, action: #selector(runsButtonPressed), for: .touchUpInside)
        self.addArrangedSubview(runsButton)
        
        unlockedButton.titleLabel?.textAlignment = .center
        _ = unlockedButton.titleLabel?.mediumBold()
        unlockedButton.setTitle(rightTitle, for: .normal)
        unlockedButton.setTitleColor(.secondaryLabel, for: .normal)
        unlockedButton.addTarget(self, action: #selector(unlockedButtonPressed), for: .touchUpInside)
        self.addArrangedSubview(unlockedButton)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func runsButtonPressed() {
        delegate?.segmentLeftButtonPressed()
        
        UIView.transition(with: runsButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.runsButton.setTitleColor(.white, for: .normal)
        }
        UIView.transition(with: unlockedButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.unlockedButton.setTitleColor(.secondaryLabel, for: .normal)
        }
    }
    
    @objc private func unlockedButtonPressed() {
        delegate?.segmentRightButtonPressed()
        
        UIView.transition(with: runsButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.runsButton.setTitleColor(.secondaryLabel, for: .normal)
        }
        UIView.transition(with: unlockedButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.unlockedButton.setTitleColor(.white, for: .normal)
        }
    }
}
