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
    let gpxFileName: String
    let centerCoordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    let steps: Int
    
    var region: MKCoordinateRegion {
        MKCoordinateRegion(center: centerCoordinate, span: span)
    }
}

struct MarathonData {
    
    static func getCurrentMarathon() -> Marathon {
        var currentWeek = Date.currentWeek()
        
        // add marathon testing
//        currentWeek = 32
        
        return marathonsByWeekOfYear[currentWeek] ?? marathonsByWeekOfYear[13]!
    }
    
    static let marathonsByWeekOfYear: [Int: Marathon] = [
        13: Marathon(title: "New York\nMarathon\nin steps",
                 gpxFileName: "NYCMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 40.71588675681417, longitude: -74.01905943032843),
                 span: MKCoordinateSpan(latitudeDelta: 0.3298624346496055, longitudeDelta: 0.2226401886051832),
                 steps: 60120),
        
        14: Marathon(title: "Athens\nMarathon\nin steps",
                 gpxFileName: "AthensMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 38.06201773742805, longitude: 23.88589039374063),
                 span: MKCoordinateSpan(latitudeDelta: 0.599918268596987, longitudeDelta: 0.4158423986708186),
                 steps: 60663),
        
        15: Marathon(title: "Boston\nMarathon\nin steps",
                 gpxFileName: "BostonMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 42.31878632648681, longitude: -71.29739497153169),
                 span: MKCoordinateSpan(latitudeDelta: 0.7585921151221342, longitudeDelta: 0.5603891477298788),
                 steps: 60818),
        
        16: Marathon(title: "Calais\nMarathon\nin steps",
                 gpxFileName: "CalaisMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 50.85608676017052, longitude: 1.7105548327002038),
                 span: MKCoordinateSpan(latitudeDelta: 0.3812118753885656, longitudeDelta: 0.32985037175532916),
                 steps: 62482),

        17: Marathon(title: "Fuerte\nMarathon\nin steps",
                 gpxFileName: "FuerteMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 28.719594780727697, longitude: -13.941798763458294),
                 span: MKCoordinateSpan(latitudeDelta: 0.2792011533932701, longitudeDelta: 0.17389747861078142),
                 steps: 60136),
        
        18: Marathon(title: "Great\nOcean Road\nMarathon\nin steps",
                 gpxFileName: "GreatOceanRoadMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: -38.657069530296695, longitude: 143.81591198965228),
                 span: MKCoordinateSpan(latitudeDelta: 0.5782065330188715, longitudeDelta: 0.40444118260995765),
                 steps: 63791),
        
        19: Marathon(title: "Kaunas\nMarathon\nin steps",
                 gpxFileName: "KaunasMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 54.912947755642, longitude: 23.941856384123014),
                 span: MKCoordinateSpan(latitudeDelta: 0.3099376061539729, longitudeDelta: 0.29451538824405077),
                 steps: 60467),
        
        20: Marathon(title: "Okinawa\nMarathon\nin steps",
                 gpxFileName: "OkinawaMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 26.33811915883177, longitude: 127.82743233710639),
                 span: MKCoordinateSpan(latitudeDelta: 0.2286997701270863, longitudeDelta: 0.13938997600371295),
                 steps: 59269
                ),
        
        21: Marathon(title: "Round Auckland\nMarathon\nin steps",
                 gpxFileName: "RoundAucklandMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: -36.8789568143523, longitude: 174.75341232474167),
                 span: MKCoordinateSpan(latitudeDelta: 0.2893701533702995, longitudeDelta: 0.19759768594875027),
                 steps: 60275
                ),
        
        22: Marathon(title: "Bhutan\nMarathon\nin steps",
                 gpxFileName: "BhutanMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 27.687285938934, longitude: 89.79075023757484),
                 span: MKCoordinateSpan(latitudeDelta: 0.47246024620439897, longitudeDelta: 0.2914376030924615),
                 steps: 60119
                ),
        
        23: Marathon(title: "Tucson\nMarathon\nin steps",
                 gpxFileName: "TucsonMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 32.21879980087396, longitude: -110.9817106432445),
                 span: MKCoordinateSpan(latitudeDelta: 0.09449783568575754, longitudeDelta: 0.19854600953998158),
                 steps: 60033
                ),
        
        24: Marathon(title: "Vancouver\nMarathon\nin steps",
                 gpxFileName: "VancouverMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 49.264796255442356, longitude: -123.17579659928514),
                 span: MKCoordinateSpan(latitudeDelta: 0.2398689119721169, longitudeDelta: 0.2007784404449069),
                 steps: 61168
                ),
        
        25: Marathon(title: "Beacons\nMarathon\nin steps",
                 gpxFileName: "BeaconsMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 51.8767911633905, longitude: -3.342025105544787),
                 span: MKCoordinateSpan(latitudeDelta: 0.2506334343346026, longitudeDelta: 0.22175351096449303),
                 steps: 60528
                ),
                
        26: Marathon(title: "Bellingham Bay\nMarathon\nin steps",
                 gpxFileName: "BellinghamBayMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 48.76611619509299, longitude: -122.57453635683568),
                 span: MKCoordinateSpan(latitudeDelta: 0.30667296089279006, longitudeDelta: 0.25413694601579095),
                 steps: 60493
                ),
                        
        27: Marathon(title: "Buckeye\nMarathon\nin steps",
                 gpxFileName: "BuckeyeMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 33.56191514166886, longitude: -112.68463384949983),
                 span: MKCoordinateSpan(latitudeDelta: 0.4167960039967866, longitudeDelta: 0.2732089248652727),
                 steps: 60134
                ),
                
        28: Marathon(title: "Cape Peninsula\nMarathon\nin steps",
                 gpxFileName: "CapePeninsulaMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: -34.03347247527706, longitude: 18.43795532880132),
                 span: MKCoordinateSpan(latitudeDelta: 0.43330553432979, longitudeDelta: 0.28560001348096975),
                 steps: 61259
                ),
                
        29: Marathon(title: "Hayden Lake\nMarathon\nin steps",
                 gpxFileName: "HaydenLakeMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 47.77790105900975, longitude: -116.71680864059869),
                 span: MKCoordinateSpan(latitudeDelta: 0.18084785165452644, longitudeDelta: 0.14699629483591536),
                 steps: 60252
                ),
                
        30: Marathon(title: "Holland Haven\nMarathon\nin steps",
                 gpxFileName: "HollandHavenMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 42.923232554836396, longitude: -86.1945641933043),
                 span: MKCoordinateSpan(latitudeDelta: 0.3771343064685482, longitudeDelta: 0.281315193229716),
                 steps: 60303
                ),
                
        31: Marathon(title: "Sandman\nMarathon\nin steps",
                 gpxFileName: "SandmanMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.195416971002594, longitude: -4.320565513245658),
                 span: MKCoordinateSpan(latitudeDelta: 0.32572169475001544, longitudeDelta: 0.37213920358449837),
                 steps: 60741
                ),
    ]
}
