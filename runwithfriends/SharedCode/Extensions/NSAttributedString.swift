//
//  NSAttributedString.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 14/3/25.
//

import UIKit

extension NSMutableAttributedString {
    var boldFont: UIFont { return UIFont.QuicksandBold(size: 22) }
    var normalFont: UIFont { return UIFont.Quicksand(size: 22) }
    
    public func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    public func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
