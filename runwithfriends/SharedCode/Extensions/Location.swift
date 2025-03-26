//
//  Location.swift
//  runwithfriends
//
//  Created by xavier chia on 13/3/24.
//

import CoreLocation

// MARK: Helpers
extension CLLocationCoordinate2D {
    func obscured() -> CLLocationCoordinate2D {
        let latitude = self.latitude + Double.random(in: -0.05...0.05)
        let longitude = self.longitude + Double.random(in: -0.05...0.05)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
