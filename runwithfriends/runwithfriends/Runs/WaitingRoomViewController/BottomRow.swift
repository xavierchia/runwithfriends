//
//  BottomRow.swift
//  runwithfriends
//
//  Created by xavier chia on 13/11/23.
//

import UIKit

class BottomRow: UIView, CustomViewProtocol {
    
    @IBOutlet var contentView: UIView!
    
    let identifier = "BottomRow"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(for: identifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(for: identifier)
    }
}
