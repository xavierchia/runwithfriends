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
//        currentWeek = 33
        
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
        
        23: Marathon(title: "Cebu\nMarathon\nin steps",
                 gpxFileName: "CebuMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 10.288668357852982, longitude: 123.88174221956855),
                 span: MKCoordinateSpan(latitudeDelta: 0.24144596343587565, longitudeDelta: 0.1340376173466069),
                 steps: 60204
                ),
        
        24: Marathon(title: "Leeds\nMarathon\nin steps",
                 gpxFileName: "LeedsMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.86912908307382, longitude: -1.6222510400110437),
                 span: MKCoordinateSpan(latitudeDelta: 0.20655971566657882, longitudeDelta: 0.191351140349989),
                 steps: 61361
                ),
        
        25: Marathon(title: "Paris\nMarathon\nin steps",
                 gpxFileName: "ParisMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 48.85063842081964, longitude: 2.340887843462061),
                 span: MKCoordinateSpan(latitudeDelta: 0.165476641290347, longitudeDelta: 0.3486521109872509),
                 steps: 60343
                ),
        
        26: Marathon(title: "Rome\nMarathon\nin steps",
                 gpxFileName: "RomeMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 41.899998029154496, longitude: 12.47345306051092),
                 span: MKCoordinateSpan(latitudeDelta: 0.12882686076494565, longitudeDelta: 0.09454053780581262),
                 steps: 61146
                ),
        
        27: Marathon(title: "Seoul\nMarathon\nin steps",
                 gpxFileName: "SeoulMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 37.54081226992193, longitude: 127.02531523477654),
                 span: MKCoordinateSpan(latitudeDelta: 0.14455122532028497, longitudeDelta: 0.2599643409570689),
                 steps: 60757
                ),
        
        28: Marathon(title: "Shakespeare\nMarathon\nin steps",
                 gpxFileName: "ShakespeareMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 52.16378169841238, longitude: -1.7495618821167276),
                 span: MKCoordinateSpan(latitudeDelta: 0.13991856117871038, longitudeDelta: 0.1245929145218927),
                 steps: 60610
                ),
        
        29: Marathon(title: "Tokyo\nMarathon\nin steps",
                 gpxFileName: "TokyoMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 35.68341106232136, longitude: 139.734212182128),
                 span: MKCoordinateSpan(latitudeDelta: 0.09969001968974567, longitudeDelta: 0.21647832730556615),
                 steps: 61020
                ),
        
        30: Marathon(title: "Tucson\nMarathon\nin steps",
                 gpxFileName: "TucsonMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 32.21879980087396, longitude: -110.9817106432445),
                 span: MKCoordinateSpan(latitudeDelta: 0.09449783568575754, longitudeDelta: 0.19854600953998158),
                 steps: 60033
                ),
        
        31: Marathon(title: "Vancouver\nMarathon\nin steps",
                 gpxFileName: "VancouverMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 49.264796255442356, longitude: -123.17579659928514),
                 span: MKCoordinateSpan(latitudeDelta: 0.2398689119721169, longitudeDelta: 0.2007784404449069),
                 steps: 61168
                ),
        
        32: Marathon(title: "Ventura\nMarathon\nin steps",
                 gpxFileName: "VenturaMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 34.37907239741961, longitude: -119.25616223627699),
                 span: MKCoordinateSpan(latitudeDelta: 0.2912229149009491, longitudeDelta: 0.19273914347496657),
                 steps: 60741
                ),
    ]
}
