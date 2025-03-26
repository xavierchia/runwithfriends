//
//  CLLocationCoordinate2D.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 18/3/25.
//

import UIKit
import MapKit
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    /// Allows direct comparison of coordinates
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    /// Compares coordinates with a specified precision
    /// - Parameter precision: The decimal precision to use for comparison (default: 5 decimals)
    /// - Returns: True if coordinates are equal within the specified precision
    public func equals(to coordinate: CLLocationCoordinate2D, precision: Int = 5) -> Bool {
        let latEqual = abs(self.latitude - coordinate.latitude) < pow(10.0, Double(-precision))
        let lonEqual = abs(self.longitude - coordinate.longitude) < pow(10.0, Double(-precision))
        return latEqual && lonEqual
    }
}
