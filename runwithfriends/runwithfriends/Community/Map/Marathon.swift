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
        var currentWeek = Date.currentWeek()
        
        // test
        currentWeek = 26
        
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
        
        Marathon(title: "Kaunas\nMarathon\nin steps",
                 weekOfYear: 19,
                 gpxFileName: "KaunasMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 54.912947755642, longitude: 23.941856384123014),
                 span: MKCoordinateSpan(latitudeDelta: 0.3099376061539729, longitudeDelta: 0.29451538824405077)),
        
        Marathon(title: "Okinawa\nMarathon\nin steps",
                 weekOfYear: 20,
                 gpxFileName: "OkinawaMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 26.33811915883177, longitude: 127.82743233710639),
                 span: MKCoordinateSpan(latitudeDelta: 0.2286997701270863, longitudeDelta: 0.13938997600371295)
                ),
        
        Marathon(title: "Round Auckland\nMarathon\nin steps",
                 weekOfYear: 21,
                 gpxFileName: "RoundAucklandMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: -36.8789568143523, longitude: 174.75341232474167),
                 span: MKCoordinateSpan(latitudeDelta: 0.2893701533702995, longitudeDelta: 0.19759768594875027)
                ),
        
        Marathon(title: "Bhutan\nMarathon\nin steps",
                 weekOfYear: 22,
                 gpxFileName: "BhutanMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 27.687285938934, longitude: 89.79075023757484),
                 span: MKCoordinateSpan(latitudeDelta: 0.47246024620439897, longitudeDelta: 0.2914376030924615)
                ),
        
        Marathon(title: "Cebu\nMarathon\nin steps",
                 weekOfYear: 23,
                 gpxFileName: "CebuMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 10.288668357852982, longitude: 123.88174221956855),
                 span: MKCoordinateSpan(latitudeDelta: 0.24144596343587565, longitudeDelta: 0.1340376173466069)
                ),
        
        Marathon(title: "Leeds\nMarathon\nin steps",
                 weekOfYear: 24,
                 gpxFileName: "LeedsMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.86912908307382, longitude: -1.6222510400110437),
                 span: MKCoordinateSpan(latitudeDelta: 0.20655971566657882, longitudeDelta: 0.191351140349989)
                ),
        
        Marathon(title: "Manchester\nMarathon\nin steps",
                 weekOfYear: 25,
                 gpxFileName: "ManchesterMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.4402963515844, longitude: -2.2869387167788258),
                 span: MKCoordinateSpan(latitudeDelta: 0.17492756144854837, longitudeDelta: 0.16040798667139589)
                ),
        
        Marathon(title: "Nunavut\nMarathon\nin steps",
                 weekOfYear: 26,
                 gpxFileName: "NunavutMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.4402963515844, longitude: -2.2869387167788258),
                 span: MKCoordinateSpan(latitudeDelta: 0.17492756144854837, longitudeDelta: 0.16040798667139589)
                ),
        
         
    ]
}

// add kaunas to leeds 28
