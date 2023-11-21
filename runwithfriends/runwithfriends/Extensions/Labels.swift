//
//  Labels.swift
//  runwithfriends
//
//  Created by xavier chia on 30/10/23.
//

import UIKit

// Colors
// Background button color: .systemFill
// Disabled or unselected font color: .secondaryLabel
// Accent: .accentColor


extension UILabel {
    func largeLightScaled() -> UILabel {
        let scaleFactor: Float = Float(UIScreen.main.bounds.height) / 852.0
        let fontSize = CGFloat(70 * scaleFactor)
        let customFont = UIFont.systemFont(ofSize: fontSize, weight: .light)
        self.font = UIFontMetrics(forTextStyle: .extraLargeTitle).scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    
    func mediumBold() -> UILabel {
        let customFont = UIFont.systemFont(ofSize: 24, weight: .bold)
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
    
    func multiLine() -> UILabel {
        self.numberOfLines = 0
        return self
    }
}

extension UIFont {
  var bold: UIFont {
    return with(traits: .traitBold)
  } // bold

  var italic: UIFont {
    return with(traits: .traitItalic)
  } // italic

  var boldItalic: UIFont {
      return with(traits: [.traitBold, .traitItalic])
  } // boldItalic


  func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
      return self
    } // guard

    return UIFont(descriptor: descriptor, size: 0)
  } // with(traits:)
} // extension
