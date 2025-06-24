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
//        currentWeek = 52
        
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
        
        32: Marathon(title: "Swiss Alpine\nMarathon\nin steps",
                 gpxFileName: "SwissAlpineMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 46.85458047025109, longitude: 9.242401354039336),
                 span: MKCoordinateSpan(latitudeDelta: 0.24109360218598397, longitudeDelta: 0.19257046496920083),
                 steps: 61092
                ),
        
        33: Marathon(title: "Coast to Coast\nMarathon\nin steps",
                 gpxFileName: "CoastToCoastMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 51.14890018620591, longitude: 1.2078652510074985),
                 span: MKCoordinateSpan(latitudeDelta: 0.5534085149453958, longitudeDelta: 0.4818778740175933),
                 steps: 60426
                ),
        
        34: Marathon(title: "Aachen\nMarathon\nin steps",
                 gpxFileName: "AachenMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 50.69671363285187, longitude: 6.091359154895335),
                 span: MKCoordinateSpan(latitudeDelta: 0.21098036139572685, longitudeDelta: 0.18193360728906427),
                 steps: 60495
                ),
        
        35: Marathon(title: "Bakewell\nMarathon\nin steps",
                 gpxFileName: "BakewellMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.21534817761688, longitude: -1.7400841387548487),
                 span: MKCoordinateSpan(latitudeDelta: 0.2626808569624757, longitudeDelta: 0.23961066435393086),
                 steps: 60485
                ),
        
        36: Marathon(title: "Barbury Castle\nMarathon\nin steps",
                 gpxFileName: "BarburyCastleMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 51.571968625979565, longitude: -1.6718555270347857),
                 span: MKCoordinateSpan(latitudeDelta: 0.33605044636614423, longitudeDelta: 0.2953300423661709),
                 steps: 61555
                ),
        
        37: Marathon(title: "Berryfields\nMarathon\nin steps",
                 gpxFileName: "BerryfieldsMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 51.84097688141144, longitude: -0.7894297278427735),
                 span: MKCoordinateSpan(latitudeDelta: 0.4030633501077858, longitudeDelta: 0.3563352337249537),
                 steps: 62059
                ),
        
        38: Marathon(title: "Bielsa\nMarathon\nin steps",
                 gpxFileName: "BielsaMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 42.708894468074185, longitude: 0.3596079806158722),
                 span: MKCoordinateSpan(latitudeDelta: 0.5978445547405471, longitudeDelta: 0.453160965391346),
                 steps: 61739
                ),
        
        39: Marathon(title: "Brighton Beach\nMarathon\nin steps",
                 gpxFileName: "BrightonBeachMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: -37.85950541798401, longitude: 145.03971744685288),
                 span: MKCoordinateSpan(latitudeDelta: 0.3194031685227472, longitudeDelta: 0.287112303423271),
                 steps: 60909
                ),
        
        40: Marathon(title: "Durham\nMarathon\nin steps",
                 gpxFileName: "DurhamMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 35.97748135273559, longitude: -78.9282650916153),
                 span: MKCoordinateSpan(latitudeDelta: 0.16310065567964926, longitudeDelta: 0.11008814824626256),
                 steps: 60195
                ),
        
        41: Marathon(title: "Kinsol\nMarathon\nin steps",
                 gpxFileName: "KinsolTrestleMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 48.60073989557082, longitude: -123.62431573623829),
                 span: MKCoordinateSpan(latitudeDelta: 0.44347165325517324, longitudeDelta: 0.36629584873747945),
                 steps: 61462
                ),
        
        42: Marathon(title: "Light up the lakes\nMarathon\nin steps",
                 gpxFileName: "LightUpTheLakesMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 54.39863177395313, longitude: -3.148102105566462),
                 span: MKCoordinateSpan(latitudeDelta: 0.23539466244472607, longitudeDelta: 0.22086836517313024),
                 steps: 60583
                ),
        
        43: Marathon(title: "Longford\nMarathon\nin steps",
                 gpxFileName: "LongfordMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.79530640358901, longitude: -7.854300053567845),
                 span: MKCoordinateSpan(latitudeDelta: 0.259982175608485, longitudeDelta: 0.24041603557308555),
                 steps: 60354
                ),
        
        44: Marathon(title: "Manchester\nMarathon\nin steps",
                 gpxFileName: "ManchesterMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.63301737152056, longitude: -2.118723978214487),
                 span: MKCoordinateSpan(latitudeDelta: 0.3788813097013417, longitudeDelta: 0.3493839041055935),
                 steps: 60402
                ),
        
        45: Marathon(title: "Manitou\nMarathon\nin steps",
                 gpxFileName: "ManitouMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 42.25005628229398, longitude: -74.0822518302387),
                 span: MKCoordinateSpan(latitudeDelta: 0.30935893062633824, longitudeDelta: 0.22828102673653916),
                 steps: 60722
                ),
        
        46: Marathon(title: "Mud Mountain\nMarathon\nin steps",
                 gpxFileName: "MudMountainMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 47.17629735681361, longitude: -122.0953305814743),
                 span: MKCoordinateSpan(latitudeDelta: 0.5561502961022171, longitudeDelta: 0.4469021111612079),
                 steps: 60398
                ),
        
        47: Marathon(title: "Musselburgh\nMarathon\nin steps",
                 gpxFileName: "MusselburghMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 56.0174569674746, longitude: -2.7654727319948287),
                 span: MKCoordinateSpan(latitudeDelta: 0.8045887168405628, longitudeDelta: 0.7862745136097371),
                 steps: 60665
                ),
        
        48: Marathon(title: "Snowdonia\nMarathon\nin steps",
                 gpxFileName: "SnowdoniaMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 53.087914437652465, longitude: -4.081364432314987),
                 span: MKCoordinateSpan(latitudeDelta: 0.20944963620668489, longitudeDelta: 0.1904883957559238),
                 steps: 62881
                ),
        
        49: Marathon(title: "Toledo\nMarathon\nin steps",
                 gpxFileName: "ToledoMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 41.62558907568954, longitude: -83.57947819675391),
                 span: MKCoordinateSpan(latitudeDelta: 0.22307411298950797, longitudeDelta: 0.1630059891674307),
                 steps: 60294
                ),
        
        50: Marathon(title: "Toronto\nMarathon\nin steps",
                 gpxFileName: "TorontoMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 43.7200440561874, longitude: -79.40031285217906),
                 span: MKCoordinateSpan(latitudeDelta: 0.32624754658051813, longitudeDelta: 0.24657008127424263),
                 steps: 60267
                ),
        
        51: Marathon(title: "Tregastel\nMarathon\nin steps",
                 gpxFileName: "TregastelMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 48.792737531298506, longitude: -3.520522140991255),
                 span: MKCoordinateSpan(latitudeDelta: 0.20765438660025382, longitudeDelta: 0.1721725239220362),
                 steps: 60782
                ),
        
        52: Marathon(title: "Verbier\nMarathon\nin steps",
                 gpxFileName: "VerbierMarathon",
                 centerCoordinate: CLLocationCoordinate2D(latitude: 46.06559401076846, longitude: 7.243147049153979),
                 span: MKCoordinateSpan(latitudeDelta: 0.19785063419053017, longitudeDelta: 0.15575715380027333),
                 steps: 60927
                ),
    ]
}
