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
    
    func configure(with cellData: Run) {
        guard cellData.start_date != 0 else {
            title.linesCornerRadius = 3
            subtitle.linesCornerRadius = 3
            self.showAnimatedSkeleton(usingColor: .lightGray)
            self.layoutSkeletonIfNeeded()
            return
        }
        self.stopSkeletonAnimation()
        self.hideSkeleton()
        
        let canJoin = cellData.runners.count < 25
        let textColor: UIColor = canJoin ? .accent : .gray
        
        self.selectionStyle = .none // Stops line separator from disappearing when tapped

        guard let displayTime = cellData.start_date.getDate().getDisplayTime() else { return }
        let rawTimeString = displayTime.time
        let rawAmOrPmString = displayTime.amOrPm
        
        // Configure the time label
        let attributedString = NSMutableAttributedString()
        let timeString = NSAttributedString(string: String(rawTimeString),
                                            attributes: [.font: UIFont.Kefir(size: 34),
                                                         .foregroundColor: UIColor.moss])
        let amOrPmString =  NSAttributedString(string: String(rawAmOrPmString),
                                               attributes: [.font: UIFont.Kefir(size: 17),
                                                            .foregroundColor: UIColor.moss])
        attributedString.append(timeString)
        attributedString.append(amOrPmString)
        title.attributedText = attributedString
        
        // Configure the runners label
        subtitle.text = "\(cellData.runners.count) / 25 runners"
        subtitle.textColor = .moss
        subtitle.font = UIFont.Kefir(size: 13)
        
        // Configure the right button
        rightButton.isEnabled = canJoin
        rightButton.titleLabel?.font = UIFont.KefirBold(size: 17)
        rightButton.setTitle("JOIN", for: .normal)
        rightButton.setTitle("FULL", for: .disabled)
        rightButton.backgroundColor = .clear
        rightButton.layer.borderColor = textColor.cgColor
        rightButton.layer.borderWidth = 3
    }
    
    func configure(with cellData: FriendCellData) {
        guard cellData.name != "dummy" else {
            title.linesCornerRadius = 3
            subtitle.linesCornerRadius = 3
            self.showAnimatedGradientSkeleton()
            self.layoutSkeletonIfNeeded()
            return
        }
        self.stopSkeletonAnimation()
        self.hideSkeleton()
        
        self.selectionStyle = .none // Stops line separator from disappearing when tapped
        title.text = cellData.name
        title.textColor = .secondaryLabel
        subtitle.textColor = .secondaryLabel

        // Friend has not joined an upcoming run
//        if let runsTogether = cellData.runsTogether {
//            subtitle.text = "ran together \(runsTogether) times"
//            subtitle.font = UIFont.systemFont(ofSize: 17, weight: .light)
//            rightButton.isHidden = true
//            return
//        } else {
//            // Friend is in an upcoming run
//            guard let displayTime = cellData..getDisplayTime() else { return }
//            let time = displayTime.time
//            let amOrPm = displayTime.amOrPm
//            if let canJoin = cellData.joinRunData?.canJoin {
//                // Configure the time label
//                let attributedString = NSMutableAttributedString()
//                let timeString = NSAttributedString(string: "is running at \(time)",
//                                                    attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .light)])
//                let amOrPmString =  NSAttributedString(string: amOrPm,
//                                                       attributes: [.font: UIFont.systemFont(ofSize: 8.5, weight: .light)])
//                attributedString.append(timeString)
//                attributedString.append(amOrPmString)
//                subtitle.attributedText = attributedString
//                
//                rightButton.isEnabled = canJoin
//                rightButton.setTitle("JOIN", for: .normal)
//                rightButton.setTitle("FULL", for: .disabled)
//                
//                if canJoin {
//                    title.textColor = .white
//                    subtitle.textColor = .white
//                }
//            }
//        }
    }
}
