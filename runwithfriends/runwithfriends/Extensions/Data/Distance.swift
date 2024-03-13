//
//  Distance.swift
//  runwithfriends
//
//  Created by Xavier Chia on 14/2/24.
//

import UIKit
import CoreLocation
extension Int {
    var value: String {
        if self > 1000 {
            let kmValue: Double = Double(self) / 1000
            return String(format: "%.2f", kmValue)
        } else {
            return String(self)
        }
    }
    
    var metric: String {
        if self > 1000 {
            return "Kilometers"
        } else {
            return "Meters"
        }
    }
    
    var valueShort: String {
        if self > 1000 {
            let kmValue: Double = Double(self) / 1000
            return String(format: "%.1f", kmValue)
        } else {
            return String(self)
        }
    }
    
    var metricShort: String {
        if self > 1000 {
            return "km"
        } else {
            return "m"
        }
    }
    
    var valueKM: String {
        let kmValue: Double = Double(self) / 1000
        return String(format: "%.1f", kmValue)
    }
}
