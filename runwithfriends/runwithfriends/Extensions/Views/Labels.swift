//
//  Labels.swift
//  runwithfriends
//
//  Created by xavier chia on 30/10/23.
//

import UIKit

// Colors
// Background button color: .systemFill
// Background button color if content behind like map: .backgroundContentFill
// Disabled or unselected font color: .secondaryText
// Accent: .accentColor

class UIPaddingLabel: UILabel {

    var edgeInset: UIEdgeInsets = .zero
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: edgeInset.top, left: edgeInset.left, bottom: edgeInset.bottom, right: edgeInset.right)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + edgeInset.left + edgeInset.right, height: size.height + edgeInset.top + edgeInset.bottom)
    }
}

extension UILabel {
    func largeLightScaled() -> UILabel {
        let scaleFactor: Float = Float(UIScreen.main.bounds.height) / 852.0
        let fontSize = CGFloat(60 * scaleFactor)
        let customFont = UIFont.KefirBold(size: fontSize)
        self.font = UIFontMetrics(forTextStyle: .extraLargeTitle).scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    
    func mediumBold() -> UILabel {
        let customFont = UIFont.KefirBold(size: 24)
        self.font = UIFontMetrics(forTextStyle: .extraLargeTitle).scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    
    func accent() -> UILabel {
        self.textColor = .accent
        return self
    }
    
    func moss() -> UILabel {
        self.textColor = .moss
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

extension UIButton {
    func setFont(_ font: UIFont) {
        if #available(iOS 15.0, *) {
            self.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }
        }
        else {
            self.titleLabel?.font = font
        }
    }
}
