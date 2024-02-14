//
//  Distance.swift
//  runwithfriends
//
//  Created by Xavier Chia on 14/2/24.
//

import UIKit
import CoreLocation
extension CLLocationDistance {
    var value: String {
        if self > 1000 {
            return String(format: "%.2f", self / 1000)
        } else {
            return String(format: "%.0f", self)
        }
    }
    
    var metric: String {
        if self > 1000 {
            return "Kilometers"
        } else {
            return "Meters"
        }
    }
}
