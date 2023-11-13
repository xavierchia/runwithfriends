//
//  WaitingRoomViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 10/11/23.
//

import UIKit
import MapKit
import CoreLocation

class WaitingRoomViewController: UIViewController {
    
    let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        
        setupLocationManager()
        setupMapView()
    }
    
    private func setupLocationManager() {
        // Create a CLLocationManager and assign a delegate
        let locationManager = CLLocationManager()
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        // Request a user’s location once
        locationManager.requestLocation()
    }
    
    private func setupMapView() {
//        mapView.delegate = self
        mapView.mapType = .satelliteFlyover
        mapView.overrideUserInterfaceStyle = .dark
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        mapView.register(EmojiAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    private func setMapRegion(with coordinate: CLLocationCoordinate2D) {
        let obscuredCoordinate = coordinate.obscured()
        // Handle location update
        let span = MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
        let region = MKCoordinateRegion(center: obscuredCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🤣"))
        newPin.coordinate = obscuredCoordinate
        mapView.addAnnotation(newPin)
                
        let secondPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "😉"))
        secondPin.coordinate = CLLocationCoordinate2D(latitude: 39.9, longitude: 116.3)
        mapView.addAnnotation(secondPin)
        
        let thirdPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "😘"))
        thirdPin.coordinate = CLLocationCoordinate2D(latitude: 10.8, longitude: 106.6)
        mapView.addAnnotation(thirdPin)
    }
}

extension WaitingRoomViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            setMapRegion(with: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("getting location failed")
        // coordinates for the The Panathenaic Stadium, where the first Olympic games were held
        let coordinate = CLLocationCoordinate2D(latitude: 37.969, longitude: 23.741)
        setMapRegion(with: coordinate)
    }
}

extension CLLocationCoordinate2D {
    func obscured() -> CLLocationCoordinate2D {
        let latitude = self.latitude + Double.random(in: -0.05...0.05)
        let longitude = self.longitude + Double.random(in: -0.05...0.05)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
