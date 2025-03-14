//
//  String.swift
//  runwithfriends
//
//  Created by xavier chia on 11/11/23.
//

import UIKit

extension String {
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
    
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
               value: NSUnderlineStyle.single.rawValue,
                   range:NSMakeRange(0,attributeString.length))
        return attributeString
    }
    
    func attributedStringWithColorAndBold(_ colorizeWords: [String], color: UIColor, boldWords: [String] = [], size: CGFloat = 20) -> NSAttributedString {
        // Create a mutable attributed string based on the original string.
        let attributedString = NSMutableAttributedString(string: self)

        // Apply color and bold attributes to the specified words.
        colorizeWords.forEach { word in
            let range = (self as NSString).range(of: word)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        
        // Make the specified words bold.
        boldWords.forEach { word in
            let range = (self as NSString).range(of: word)
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.KefirMedium(size: size), range: range)
        }

        return attributedString
    }
}

extension String {
    func getDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}

extension String: Error {}
