//
//  String.swift
//  runwithfriends
//
//  Created by xavier chia on 11/11/23.
//

import UIKit

extension String {
    // For conversion of emoji to images
    func image(pointSize: CGFloat, backgroundColor: UIColor = .clear) -> UIImage {
         let font = UIFont.systemFont(ofSize: pointSize)
         let emojiSize = self.size(withAttributes: [.font: font])

         let image = UIGraphicsImageRenderer(size: emojiSize).image { context in
             backgroundColor.setFill()
             context.fill(CGRect(origin: .zero, size: emojiSize))
             self.draw(at: .zero, withAttributes: [.font: font])
         }
        
        return image.withRenderingMode(.alwaysOriginal)
     }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
               value: NSUnderlineStyle.single.rawValue,
                   range:NSMakeRange(0,attributeString.length))
        return attributeString
    }    
}

extension Int {
    func leadingZero() -> String {
        String(format: "%02d", self)
    }
}
