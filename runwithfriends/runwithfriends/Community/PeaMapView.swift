//
//  PeaMapView.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 13/3/25.
//

import Foundation
import MapKit

class PeaMapView: MKMapView, MKMapViewDelegate {
    private var coordinates = [CLLocationCoordinate2D]()
    private var stepCoordinates = [StepCoordinate]()
    
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

    func addPath() {
        // get current path coordinates
        if let nycMarathonPath = Bundle.main.path(forResource: "NYCMarathon", ofType: "gpx") {
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
        let startPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "⛩️"))
        startPin.coordinate = firstCoordinate
        self.addAnnotation(startPin)
        
        // add ending flag
        guard let lastCoordinate = coordinates.last else { return }
        let endPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🏁"))
        endPin.coordinate = lastCoordinate
        self.addAnnotation(endPin)
    }
    
    func addUserAnnotation(allUsers: [User], currentUser: User) {
        var collisions = 1.0

        let sortedUsers = allUsers.sorted { lhs, rhs in
            (lhs.week_steps ?? 0) < (rhs.week_steps ?? 0)
        }
        
        sortedUsers.enumerated().forEach { index, user in
            guard let userWeekSteps = user.week_steps,
                  let userCoordinate = PathSearch.findCoordinateForSteps(in: self.stepCoordinates, targetSteps: Double(userWeekSteps)) else {
                return
            }
            
            let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: user.emoji))
            newPin.coordinate = userCoordinate
            newPin.title = user.username
            newPin.identifier = "other"
            
            // Color pin for current user
            if user.user_id == currentUser.user_id {
                newPin.color = .lightAccent
                newPin.identifier = "user"
            }
            
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
            if userCoordinate.longitude == finalCoordinate.longitude &&
                userCoordinate.latitude == finalCoordinate.latitude {
                // If at the finish line, space them out vertically
                newPin.coordinate = CLLocationCoordinate2D(latitude: userCoordinate.latitude + 0.005 * collisions, longitude: userCoordinate.longitude)
                collisions += 1
            }
        
            self.addAnnotation(newPin)
        }
    }
    
    func selectUserAnnotation(userId: String) {
        // Find the annotation with the matching user ID
        if let userAnnotation = annotations.first(where: { annotation in
            if let emojiAnnotation = annotation as? EmojiAnnotation,
               emojiAnnotation.identifier == "user" {
                return true
            }
            return false
        }) {
            // Select the annotation
            self.selectAnnotation(userAnnotation, animated: true)
            
            // Optionally center the map on this annotation
            let span = MKCoordinateSpan(latitudeDelta: 0.0392143104880347, longitudeDelta: 0.02828775277940565)
            let region = MKCoordinateRegion(center: userAnnotation.coordinate, span: span)
            self.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = overlay.title == "main" ? UIColor.accent : .darkerGray
        renderer.lineWidth = overlay.title == "main" ? 5 : 7
        renderer.lineCap = .round
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(mapView.region.span)
    }
}
