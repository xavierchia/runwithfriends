//
//  Int.swift
//  runwithfriends
//
//  Created by Xavier Chia on 6/3/24.
//

import Foundation

extension Int {
    func leadingZero() -> String {
        String(format: "%02d", self)
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
