//
//  Labels.swift
//  runwithfriends
//
//  Created by xavier chia on 30/10/23.
//

import UIKit

extension UILabel {
    func largeLightScaled() -> UILabel {
        let scaleFactor: Float = Float(UIScreen.main.bounds.height) / 852.0
        let fontSize = CGFloat(70 * scaleFactor)
        guard let customFont = UIFont(name: "HelveticaNeue-Light", size: fontSize) else {
            fatalError("Failed to load the largeFont() font.")
        }
        self.font = UIFontMetrics(forTextStyle: .extraLargeTitle).scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    
    func mediumLight() -> UILabel {
        guard let customFont = UIFont(name: "HelveticaNeue-Light", size: 20) else {
            fatalError("Failed to load the mediumRegular() font.")
        }
        self.font = UIFontMetrics(forTextStyle: .extraLargeTitle).scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    
    func orange() -> UILabel {
        self.textColor = .systemOrange
        return self
    }
    
    func accent() -> UILabel {
        self.textColor = .accent
        return self
    }
    
    func white() -> UILabel {
        self.textColor = .white
        return self
    }
    
    func gray() -> UILabel {
        self.textColor = .gray
        return self
    }
    
    func multiLine() -> UILabel {
        self.numberOfLines = 0
        return self
    }
}
