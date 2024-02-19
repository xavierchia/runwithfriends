//
//  UIFont.swift
//  runwithfriends
//
//  Created by Xavier Chia on 8/2/24.
//

import UIKit

extension UIFont {
    static func Kefir(size: CGFloat) -> UIFont {
        UIFont(name: "Kefir-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func KefirBold(size: CGFloat) -> UIFont {
        UIFont(name: "Kefir-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func KefirLight(size: CGFloat) -> UIFont {
        UIFont(name: "Kefir-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
}
