import Foundation
import CoreLocation

struct StepCoordinate {
    let steps: Double
    let coordinate: CLLocationCoordinate2D
}

class Parser {
    private let coordinateParser = CoordinatesParser()
    
    func parseCoordinatesAndSteps(fromGpxFile filePath: String) -> (coordinates: [CLLocationCoordinate2D], stepCoordinates: [StepCoordinate])? {
        guard let data = FileManager.default.contents(atPath: filePath) else { return nil }
    
        coordinateParser.prepare()
    
        let parser = XMLParser(data: data)
        parser.delegate = coordinateParser

        let success = parser.parse()
    
        guard success else { return nil }
        
        // Create stepCoordinates here
        let coordinates = coordinateParser.coordinates
        var stepCoordinates = [StepCoordinate]()
        
        if !coordinates.isEmpty {
            var cumulativeSteps = 0.0
            var lastCoordinate = CLLocation(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude)
            
            // Add the starting point
            stepCoordinates.append(StepCoordinate(steps: cumulativeSteps, coordinate: coordinates[0]))
            
            // Process remaining coordinates
            for i in 1..<coordinates.count {
                let currentCoordinate = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
                let nextDistance = currentCoordinate.distance(from: lastCoordinate)
                cumulativeSteps += nextDistance / 0.7 // Convert distance to steps
                
                stepCoordinates.append(StepCoordinate(steps: cumulativeSteps, coordinate: coordinates[i]))
                lastCoordinate = currentCoordinate
            }
        }
        
        return (coordinates, stepCoordinates)
    }
}

class CoordinatesParser: NSObject, XMLParserDelegate  {
    private(set) var coordinates = [CLLocationCoordinate2D]()

    func prepare() {
        coordinates = [CLLocationCoordinate2D]()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        guard elementName == "trkpt" else { return }
        guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
        guard let lat = Double(latString), let lon = Double(lonString) else { return }
        guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else { return }

        coordinates.append(CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees))
    }
}
