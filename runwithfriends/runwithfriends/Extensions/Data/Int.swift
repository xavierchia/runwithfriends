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
