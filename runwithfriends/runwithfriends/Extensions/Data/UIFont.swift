//
//  UIFont.swift
//  runwithfriends
//
//  Created by Xavier Chia on 8/2/24.
//

import UIKit

extension UIFont {
    static func chalkboard(size: CGFloat) -> UIFont {
        UIFont(name: "ChalkboardSE-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func chalkboardBold(size: CGFloat) -> UIFont {
        UIFont(name: "ChalkboardSE-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func chalkboardLight(size: CGFloat) -> UIFont {
        UIFont(name: "ChalkboardSE-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }

}
