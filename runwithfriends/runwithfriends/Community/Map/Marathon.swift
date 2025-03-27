//
//  Marathon.swift
//  runwithfriends
//
//  Created by xavier chia on 27/3/25.
//

import Foundation
import MapKit

struct Marathon {
    let title: String
    let weekOfYear: Int
    let gpxFileName: String
    let centerCoordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    
    var region: MKCoordinateRegion {
        MKCoordinateRegion(center: centerCoordinate, span: span)
    }
}

struct MarathonData {
    
    static func getCurrentMarathon() -> Marathon {
        let currentWeek = Date.currentWeek()
        return marathons.first { marathon in
            marathon.weekOfYear == currentWeek
        } ?? marathons.first!
    }
    
    static let marathons: [Marathon] = [
        Marathon(title: "New York\nMarathon\nin steps",
                 weekOfYear: 13,
                 gpxFileName: "NYCMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 40.71588675681417, longitude: -74.01905943032843),
                 span: MKCoordinateSpan(latitudeDelta: 0.3298624346496055, longitudeDelta: 0.2226401886051832))
        ]
}
