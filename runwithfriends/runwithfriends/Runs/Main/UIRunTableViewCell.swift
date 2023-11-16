//
//  UIRunTableViewCell.swift
//  runwithfriends
//
//  Created by xavier chia on 5/11/23.
//

import UIKit

protocol UIRunTableViewCellProtocol: AnyObject {
    func cellButtonPressed(with indexPath: IndexPath)
}

class UIRunTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var runnersLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    weak var delegate: UIRunTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        print("join button press")
        guard let indexPath else { return }
        self.delegate?.cellButtonPressed(with: indexPath)
    }
    
    func configure(with cellData: CellData) {
        let textColor: UIColor = cellData.canJoin ? .white : .secondaryLabel
        
        // Stops line separator from disappearing when tapped
        self.selectionStyle = .none
        
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
        self.rightButton.isEnabled = cellData.canJoin
        self.rightButton.setTitle("JOIN", for: .normal)
        self.rightButton.setTitle("FULL", for: .disabled)
    }
}
