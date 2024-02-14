//
//  BottomRow.swift
//  runwithfriends
//
//  Created by xavier chia on 13/11/23.
//

import UIKit
import Combine

protocol BottomRowProtocol: AnyObject {
    func inviteButtonPressed()
}

class BottomRow: UIView, CustomViewProtocol {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    let identifier = "BottomRow"
    weak var delegate: BottomRowProtocol?
    var runData: Run?
    var runStage: RunSession.RunStage? {
        didSet {
            guard let runData else { return }
            let startingTime = runData.start_date.getDate()
            switch runStage {
            case .waitingRunStart:
                guard let displayTime = startingTime.getDisplayTime(padZero: false) else { return }
                // Configure the time label
                let attributedString = NSMutableAttributedString()
                let timeString = NSAttributedString(string: "Run will auto-start at \(displayTime.time)",
                                                    attributes: [.font: UIFont.chalkboardLight(size: 18)])
                attributedString.append(timeString)
                
                // Add AM/PM if showing display time
                let amOrPmString =  NSAttributedString(string: displayTime.amOrPm,
                                                       attributes: [.font: UIFont.chalkboardLight(size: 12)])
                attributedString.append(amOrPmString)
                
                self.title.attributedText = attributedString
            case .oneHourToRunStart(let countdownTime):
                self.title.font = UIFont.chalkboardLight(size: 18)
                self.title.text = "Run will auto-start in \(countdownTime)"
            default:
                return
            }
            title.textColor = .cream
            subtitle.textColor = .cream
            subtitle.font = UIFont.chalkboardLight(size: 18)
            subtitle.text = "\(runData.runners.count) / 25 runners"
        }
    }
    
    convenience init(with run: Run) {
        self.init(frame: .zero)
        self.runData = run
        rightButton.layer.borderColor = UIColor.cream.cgColor
        rightButton.layer.borderWidth = 3
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: identifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: identifier)
    }
    
    @IBAction func inviteButtonPressed(_ sender: Any) {
        self.delegate?.inviteButtonPressed()
    }
}
