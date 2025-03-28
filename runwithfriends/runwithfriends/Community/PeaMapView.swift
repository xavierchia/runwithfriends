//
//  PeaMapView.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 13/3/25.
//

import Foundation
import MapKit
import SharedCode

protocol PeaMapViewDelegate {
    func annotationViewSelected(_ annotationView: MKAnnotationView)
}

class PeaMapView: MKMapView, MKMapViewDelegate {
    var peaMapViewDelegate: PeaMapViewDelegate?

    private var coordinates = [CLLocationCoordinate2D]()
    private var stepCoordinates = [StepCoordinate]()
    private var currentMarathon: Marathon {
        return MarathonData.getCurrentMarathon()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMapDefaults()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Storyboard not supported")
    }
    
    private func configureMapDefaults() {
        self.delegate = self
        self.mapType = .satelliteFlyover
        self.register(EmojiAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    func setMapRegion() {
        self.setRegion(currentMarathon.region, animated: false)
    }

    func addPath() {
        // get current path coordinates
        if let nycMarathonPath = Bundle.main.path(forResource: currentMarathon.gpxFileName, ofType: "gpx") {
            let parser = Parser()
            if let (coordinates, stepCoordinates) = parser.parseCoordinatesAndSteps(fromGpxFile: nycMarathonPath) {
                self.coordinates = coordinates
                self.stepCoordinates = stepCoordinates
                
                let borderPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                borderPolyline.title = "border"
                self.addOverlay(borderPolyline)
                
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                polyline.title = "main"
                self.addOverlay(polyline)
            }
        }
    }
    
    func addStartAndEnd() {
        guard let firstCoordinate = coordinates.first else { return }
        let startPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "⛩️"), identifier: "start")
        startPin.coordinate = firstCoordinate
        self.addAnnotation(startPin)
        
        // add ending flag
        guard let lastCoordinate = coordinates.last else { return }
        let endPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🏁"), identifier: "end")
        endPin.coordinate = lastCoordinate
        self.addAnnotation(endPin)
    }
    
    func addUserAnnotation(allUsers: [PeaUser], currentUser: PeaUser) {
        var collisions = 1.0
        var lastCoordinate = CLLocationCoordinate2DMake(0, 0)

        let sortedUsers = allUsers.sorted { lhs, rhs in
            (lhs.week_steps ?? 0) < (rhs.week_steps ?? 0)
        }
        
        sortedUsers.enumerated().forEach { index, user in
            guard let userWeekSteps = user.week_steps,
                  let userDaySteps = user.day_steps,
                  let userCoordinate = PathSearch.findCoordinateForSteps(in: self.stepCoordinates, targetSteps: Double(userWeekSteps)) else {
                return
            }
            
            let identifier = user.user_id == currentUser.user_id ? "user" : "other"
            let newPin = EmojiAnnotation(username: user.username,
                                         emojiImage: OriginalUIImage(emojiString: user.emoji),
                                         identifier: identifier,
                                         daySteps: userDaySteps,
                                         weekSteps: userWeekSteps)
            newPin.coordinate = userCoordinate

            // Special annotations
            if index == sortedUsers.count - 1 && sortedUsers.count > 1 {
                // Crown for the user in the lead
                newPin.emojiImage = OriginalUIImage(emojiString: "👑")
            }
            
            
            /// Zombie stuff
            //            if user.username.lowercased() == "zombie" {
            //                newPin.color = .red
            //            }
            
            /// Handle potential annotation collisions
            guard let finalCoordinate = coordinates.last else { return }
            if userCoordinate == finalCoordinate {
                // If at the finish line, space them out vertically
                newPin.coordinate = CLLocationCoordinate2D(latitude: userCoordinate.latitude + 0.005 * collisions, longitude: userCoordinate.longitude)
                collisions += 1
            } else if userCoordinate == lastCoordinate {
                // If same coordinate as previous annotation, space them out horizontally
                newPin.coordinate = CLLocationCoordinate2D(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude + 0.005 * collisions)
                collisions += 1
            } else {
                // No collision
                newPin.coordinate = userCoordinate
                collisions = 1
            }
            lastCoordinate = userCoordinate
        
            self.addAnnotation(newPin)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = overlay.title == "main" ? UIColor.accent : .darkerGray
        renderer.lineWidth = overlay.title == "main" ? 5 : 7
        renderer.lineCap = .round
        return renderer
    }
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        print(mapView.region)
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        peaMapViewDelegate?.annotationViewSelected(view)
    }
}


extension PeaMapView {
    func zoomToCurrentUserContext(currentUserId: String) {
        // Find current user annotation
        guard let currentUserAnnotation = annotations.first(where: { annotation in
            if let emojiAnnotation = annotation as? EmojiAnnotation,
               emojiAnnotation.identifier == "user" {
                return true
            }
            return false
        }) else { return }
        
        // First select the user annotation
        self.selectAnnotation(currentUserAnnotation, animated: true)
        
        // Get current user location
        let currentUserCoordinate = currentUserAnnotation.coordinate
        let currentUserLocation = CLLocation(
            latitude: currentUserCoordinate.latitude,
            longitude: currentUserCoordinate.longitude
        )
        
        // Find nearest annotations of any type (other users, landmarks, start/finish)
        var nearestAnnotations: [(annotation: MKAnnotation, distance: CLLocationDistance)] = []
        
        for annotation in annotations {
            // Skip the current user annotation
            if annotation === currentUserAnnotation {
                continue
            }
            
            let otherLocation = CLLocation(
                latitude: annotation.coordinate.latitude,
                longitude: annotation.coordinate.longitude
            )
            
            let distance = currentUserLocation.distance(from: otherLocation)
            nearestAnnotations.append((annotation, distance))
        }
        
        // Sort by distance
        nearestAnnotations.sort { $0.distance < $1.distance }
        
        // Create a region that includes the current user and at least 2 nearest annotations
        var annotationsToInclude = [currentUserAnnotation]
        
        // Add up to 2 nearest annotations, if available
        let annotationsToAdd = min(2, nearestAnnotations.count)
        for i in 0..<annotationsToAdd {
            annotationsToInclude.append(nearestAnnotations[i].annotation)
        }
        
        // Calculate a map rect that includes all these annotations
        let rect = mapRectThatFits(annotations: annotationsToInclude)
        
        // Set the visible region
        self.setVisibleMapRect(rect, animated: true)
    }

    // Helper function to calculate a map rect that includes all specified annotations
    private func mapRectThatFits(annotations: [MKAnnotation]) -> MKMapRect {
        guard !annotations.isEmpty else {
            // Fallback if no annotations
            return MKMapRect(x: 0, y: 0, width: 1, height: 1)
        }
        
        let mapPoints = annotations.map { MKMapPoint($0.coordinate) }
        
        // Find the minimum and maximum map points
        var minX = mapPoints[0].x
        var minY = mapPoints[0].y
        var maxX = minX
        var maxY = minY
        
        for point in mapPoints {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }
        
        // Create a map rect that encompasses all the points
        let width = maxX - minX
        let height = maxY - minY
        
        // Add padding (extra space around the points)
        let paddingFactor: Double = 2 // 30% extra space
        return MKMapRect(x: minX - width * (paddingFactor - 1) / 2,
                        y: minY - height * (paddingFactor - 1) / 2,
                        width: width * paddingFactor,
                        height: height * paddingFactor)
    }
}
