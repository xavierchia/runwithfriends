//
//  UIFont.swift
//  runwithfriends
//
//  Created by Xavier Chia on 8/2/24.
//

import UIKit

extension UIFont {
    static func KefirBold(size: CGFloat) -> UIFont {
        UIFont(name: "Kefir-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func KefirDemiBold(size: CGFloat) -> UIFont {
        UIFont(name: "Kefir-DemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    static func KefirMedium(size: CGFloat) -> UIFont {
        UIFont(name: "Kefir-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func Kefir(size: CGFloat) -> UIFont {
        UIFont(name: "Kefir-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func KefirLight(size: CGFloat) -> UIFont {
        UIFont(name: "Kefir-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
}

extension UIFont {
    static func QuicksandBold(size: CGFloat) -> UIFont {
        UIFont(name: "Quicksand-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func QuicksandSemiBold(size: CGFloat) -> UIFont {
        UIFont(name: "Quicksand-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    static func QuicksandMedium(size: CGFloat) -> UIFont {
        UIFont(name: "Quicksand-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func Quicksand(size: CGFloat) -> UIFont {
        UIFont(name: "Quicksand-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func QuicksandLight(size: CGFloat) -> UIFont {
        UIFont(name: "Quicksand-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
}
