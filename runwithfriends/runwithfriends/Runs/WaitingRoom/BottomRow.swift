//
//  BottomRow.swift
//  runwithfriends
//
//  Created by xavier chia on 13/11/23.
//

import UIKit

protocol BottomRowProtocol: AnyObject {
    func inviteButtonPressed()
}

class BottomRow: UIView, CustomViewProtocol {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    let identifier = "BottomRow"
    weak var delegate: BottomRowProtocol?
    var timer = Timer()
    var runData: JoinRunData?
    
    convenience init(cellData: JoinRunData) {
        self.init(frame: .zero)
        self.runData = cellData
        fireTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            self.fireTimer()
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: identifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: identifier)
    }
    
    
    func fireTimer() {
        guard let runData else { return }
        let startingTime = runData.date
        let intervalToStart = startingTime.timeIntervalSince(Date())
        let runStartsInLessThanOneHour = intervalToStart < 60 * 60
        if runStartsInLessThanOneHour {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.minute, .second], from: Date(), to: startingTime)
            guard let minuteInt = components.minute,
                  let secondInt = components.second else { return }
            let minuteString = String(format: "%02d", minuteInt)
            let secondString = String(format: "%02d", secondInt)
            let countdownTime = "\(minuteString):\(secondString)"
            self.title.text = "Run will auto-start in \(countdownTime)"
        } else {
            guard let displayTime = startingTime.getDisplayTime() else { return }
            // Configure the time label
            let attributedString = NSMutableAttributedString()
            let timeString = NSAttributedString(string: "Run will auto-start at \(displayTime.time)",
                                                attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)])
            attributedString.append(timeString)
            
            // Add AM/PM if showing display time
            let amOrPmString =  NSAttributedString(string: displayTime.amOrPm,
                                                   attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
            attributedString.append(amOrPmString)
            
            self.title.attributedText = attributedString
        }
    }
    
    @IBAction func inviteButtonPressed(_ sender: Any) {
        self.delegate?.inviteButtonPressed()
    }
}
