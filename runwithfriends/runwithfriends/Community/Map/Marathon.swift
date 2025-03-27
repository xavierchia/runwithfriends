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
                 span: MKCoordinateSpan(latitudeDelta: 0.3298624346496055, longitudeDelta: 0.2226401886051832)),
        
        Marathon(title: "Athens\nMarathon\nin steps",
                 weekOfYear: 14,
                 gpxFileName: "AthensMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 38.06201773742805, longitude: 23.88589039374063),
                 span: MKCoordinateSpan(latitudeDelta: 0.599918268596987, longitudeDelta: 0.4158423986708186)),
        
        Marathon(title: "Boston\nMarathon\nin steps",
                 weekOfYear: 15,
                 gpxFileName: "BostonMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 42.31878632648681, longitude: -71.29739497153169),
                 span: MKCoordinateSpan(latitudeDelta: 0.7585921151221342, longitudeDelta: 0.5603891477298788)),
        
        Marathon(title: "Calais\nMarathon\nin steps",
                 weekOfYear: 16,
                 gpxFileName: "CalaisMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 50.85608676017052, longitude: 1.7105548327002038),
                 span: MKCoordinateSpan(latitudeDelta: 0.3812118753885656, longitudeDelta: 0.32985037175532916)),

        Marathon(title: "Fuerte\nMarathon\nin steps",
                 weekOfYear: 17,
                 gpxFileName: "FuerteMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 28.719594780727697, longitude: -13.941798763458294),
                 span: MKCoordinateSpan(latitudeDelta: 0.2792011533932701, longitudeDelta: 0.17389747861078142)),
        
        Marathon(title: "Great\nOcean Road\nMarathon\nin steps",
                 weekOfYear: 18,
                 gpxFileName: "GreatOceanRoadMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: -38.657069530296695, longitude: 143.81591198965228),
                 span: MKCoordinateSpan(latitudeDelta: 0.5782065330188715, longitudeDelta: 0.40444118260995765)),
    ]
}
