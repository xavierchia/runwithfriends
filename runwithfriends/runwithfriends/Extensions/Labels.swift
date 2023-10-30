//
//  Labels.swift
//  runwithfriends
//
//  Created by xavier chia on 30/10/23.
//

import UIKit


// ** GET SOME DYNAMIC FONT SIZING HAPPENING **

// Set the clock font size according to the height.
//  Design was done on iPhone XR with height of 896 points and font size of 98.
//if (UIScreen.main.bounds.height != 896). // Only need code if not on original design size.
//{
//    let scaleFactor: Float = Float(UIScreen.main.bounds.height) / 896.0
//    let fontSize = CGFloat(98.0 * scaleFactor)
//    self.clock.font = self.clock.font.withSize(fontSize)
//}

extension UILabel {
    func largeFont() -> UILabel {
        guard let customFont = UIFont(name: "HelveticaNeue-Light", size: 70) else {
            fatalError("Failed to load the largeFont() font.")
        }
//        let customFont = UIFont.systemFont(ofSize: 70)
        self.font = UIFontMetrics(forTextStyle: .extraLargeTitle).scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    
    func orange() -> UILabel {
        self.textColor = .systemOrange
        return self
    }
    
    func white() -> UILabel {
        self.textColor = .white
        return self
    }
    
    func multiLine() -> UILabel {
        self.numberOfLines = 0
        return self
    }
}
