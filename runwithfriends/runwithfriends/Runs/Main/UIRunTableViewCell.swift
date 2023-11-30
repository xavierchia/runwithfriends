//
//  UIRunTableViewCell.swift
//  runwithfriends
//
//  Created by xavier chia on 5/11/23.
//

import UIKit

protocol UIRunTableViewCellProtocol: AnyObject {
    func cellButtonPressed(with indexPath: IndexPath, from tableView: UITableView)
}

class UIRunTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    static let identifier = "UIRunTableViewCell"
    weak var delegate: UIRunTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        print("join button press")
        guard let indexPath, 
            let tableView else { return }
        self.delegate?.cellButtonPressed(with: indexPath, from: tableView)
    }
    
    func configure(with cellData: JoinRunData) {
        let textColor: UIColor = cellData.canJoin ? .white : .secondaryLabel
        
        // Stops line separator from disappearing when tapped
        self.selectionStyle = .none
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let dateInString = dateFormatter.string(from: cellData.date as Date)
        let dateArray = dateInString.split(separator: " ")
        guard let rawTimeString = dateArray.first,
              let rawAmOrPmString = dateArray.last else { return }
        
        // Configure the time label
        let attributedString = NSMutableAttributedString()
        let timeString = NSAttributedString(string: String(rawTimeString),
                                            attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .light),
                                                         .foregroundColor: textColor])
        let amOrPmString =  NSAttributedString(string: String(rawAmOrPmString),
                                               attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .light),
                                                            .foregroundColor: textColor])
        attributedString.append(timeString)
        attributedString.append(amOrPmString)
        title.attributedText = attributedString
        
        // Configure the runners label
        subtitle.text = cellData.runners
        subtitle.textColor = textColor
        subtitle.font = UIFont.systemFont(ofSize: 13, weight: .light)
        
        // Configure the right button
        rightButton.isEnabled = cellData.canJoin
        rightButton.setTitle("JOIN", for: .normal)
        rightButton.setTitle("FULL", for: .disabled)
    }
    
    func configure(with cellData: FriendCellData) {
        var textColor: UIColor = .secondaryLabel
        if let canJoin = cellData.joinRunData?.canJoin, canJoin {
            textColor = .white
        }

        // Stops line separator from disappearing when tapped
        self.selectionStyle = .none
        
        title.text = cellData.name
        title.textColor = textColor
        subtitle.textColor = textColor
        
        // Friend has not joined an upcoming run
        if let runsTogether = cellData.runsTogether {
            subtitle.text = "ran together \(runsTogether) times"
            subtitle.font = UIFont.systemFont(ofSize: 17, weight: .light)
            rightButton.isHidden = true
            return
        }
        
        // Friend is in an upcoming run
        if let time = cellData.joinRunData?.date,
//           let amOrPm = cellData.joinRunData?.amOrPm,
           let canJoin = cellData.joinRunData?.canJoin {
            // Configure the time label
            let attributedString = NSMutableAttributedString()
            let timeString = NSAttributedString(string: "is running at \(time)",
                                                attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .light)])
//            let amOrPmString =  NSAttributedString(string: amOrPm,
//                                                   attributes: [.font: UIFont.systemFont(ofSize: 8.5, weight: .light)])
            attributedString.append(timeString)
//            attributedString.append(amOrPmString)
            subtitle.attributedText = attributedString
            
            rightButton.isEnabled = canJoin
            rightButton.setTitle("JOIN", for: .normal)
            rightButton.setTitle("FULL", for: .disabled)
        }
    }
}
