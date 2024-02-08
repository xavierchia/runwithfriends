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

extension RunsViewController {
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
            unlockedButton.setTitleColor(.pumpkin, for: .normal)
            runsButton.setTitle(leftTitle, for: .normal)
            runsButton.addTarget(self, action: #selector(runsButtonPressed), for: .touchUpInside)
            self.addArrangedSubview(runsButton)
            
            unlockedButton.titleLabel?.textAlignment = .center
            _ = unlockedButton.titleLabel?.mediumBold()
            unlockedButton.setTitle(rightTitle, for: .normal)
            unlockedButton.setTitleColor(.gray, for: .normal)
            unlockedButton.addTarget(self, action: #selector(friendsButtonPressed), for: .touchUpInside)
            self.addArrangedSubview(unlockedButton)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc public func runsButtonPressed() {
            delegate?.segmentLeftButtonPressed()
            
            UIView.transition(with: runsButton, duration: 0.2, options: .transitionCrossDissolve) {
                self.runsButton.setTitleColor(.pumpkin, for: .normal)
            }
            UIView.transition(with: unlockedButton, duration: 0.2, options: .transitionCrossDissolve) {
                self.unlockedButton.setTitleColor(.gray, for: .normal)
            }
        }
        
        @objc public func friendsButtonPressed() {
            delegate?.segmentRightButtonPressed()
            
            UIView.transition(with: runsButton, duration: 0.2, options: .transitionCrossDissolve) {
                self.runsButton.setTitleColor(.gray, for: .normal)
            }
            UIView.transition(with: unlockedButton, duration: 0.2, options: .transitionCrossDissolve) {
                self.unlockedButton.setTitleColor(.pumpkin, for: .normal)
            }
        }
    }

}
