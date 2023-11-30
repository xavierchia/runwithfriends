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
    
    convenience init(cellData: JoinRunData) {
        self.init(frame: .zero)
        
        // Configure the time label
        let attributedString = NSMutableAttributedString()
        // If less than 1 hour, change to 'run will auto-start in 30:21"
        let timeString = NSAttributedString(string: "Run will auto-start at \(cellData.date)",
                                            attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)])
//        let amOrPmString =  NSAttributedString(string: cellData.amOrPm,
//                                               attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
        attributedString.append(timeString)
//        attributedString.append(amOrPmString)
        self.title.attributedText = attributedString
        
        self.subtitle.text = cellData.runners
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
