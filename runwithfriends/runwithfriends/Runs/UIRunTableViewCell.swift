//
//  UIRunTableViewCell.swift
//  runwithfriends
//
//  Created by xavier chia on 5/11/23.
//

import UIKit

class UIRunTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var runnersLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        print("right button press")
    }
    
    func configure(with cellData: CellData) {
        let textColor: UIColor = cellData.canJoin ? .white : .secondaryLabel
        
        // Configure the time label
        let attributedString = NSMutableAttributedString()
        let timeString = NSAttributedString(string: cellData.time,
                                            attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .light),
                                                         .foregroundColor: textColor])
        let amOrPmString =  NSAttributedString(string: cellData.amOrPm,
                                               attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .light),
                                                            .foregroundColor: textColor])
        attributedString.append(timeString)
        attributedString.append(amOrPmString)
        self.timeLabel.attributedText = attributedString
        
        // Configure the runners label
        self.runnersLabel.text = cellData.runners
        self.runnersLabel.textColor = textColor
        
        // Configure the right button
        self.rightButton.titleLabel?.text = cellData.canJoin ? "JOIN" : "FULL"
//        self.rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.rightButton.isEnabled = cellData.canJoin
    }
}
