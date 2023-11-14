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
    let bottomRow: BottomRow
    let locationManager = CLLocationManager()
    
    // coordinates for the The Panathenaic Stadium, where the first Olympic games were held
    let defaultLocation = CLLocationCoordinate2D(latitude: 37.969, longitude: 23.741)
    
    init(with cellData: CellData) {
        bottomRow = BottomRow(cellData: cellData)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupBottomRow()
        setupMapView()
    }
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        if locationManager.authorizationStatus == .notDetermined {
            print("Authorization status not determined, requesting authorization")
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("Authorization permitted, requesting location")
            locationManager.requestLocation()
        }
    }
    
    // MARK: Setup UI
    private func setupBottomRow() {
        bottomRow.delegate = self
        view.addSubview(bottomRow)
        
        NSLayoutConstraint.activate([
            bottomRow.heightAnchor.constraint(equalToConstant: 80),
            bottomRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: Setup location manager
    private func setupMapView() {
        mapView.mapType = .satelliteFlyover
        mapView.overrideUserInterfaceStyle = .dark
        view.insertSubview(mapView, belowSubview: bottomRow)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomRow.topAnchor)
        ])
                
        mapView.register(EmojiAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    private func setMapRegion(with coordinate: CLLocationCoordinate2D) {
        let obscuredCoordinate = coordinate.obscured()
        // Handle location update
        let span = MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
        let region = MKCoordinateRegion(center: obscuredCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🤣"))
        newPin.coordinate = obscuredCoordinate
        newPin.title = UserData.shared.getUsername()
        mapView.addAnnotation(newPin)
                
        let secondPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "😉"))
        secondPin.coordinate = CLLocationCoordinate2D(latitude: 39.9, longitude: 116.3)
        mapView.addAnnotation(secondPin)
        
        let thirdPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "😘"))
        thirdPin.coordinate = CLLocationCoordinate2D(latitude: 10.8, longitude: 106.6)
        mapView.addAnnotation(thirdPin)
    }
}

// MARK: CLLocationManagerDelegate
extension WaitingRoomViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            if let location = manager.location {
                print("Location authorized, setting user location")
                setMapRegion(with: location.coordinate)
            }
        } else if manager.authorizationStatus == .notDetermined {
            print("Location not authorized yet, just wait.")
        } else {
            print("Did not authorize, setting default location")
            setMapRegion(with: defaultLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Getting location passed")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Getting location failed")
    }
}

extension WaitingRoomViewController: BottomRowProtocol {
    func leaveButtonPressed() {
        self.dismiss(animated: true)
    }
}

// MARK: Helpers
extension CLLocationCoordinate2D {
    func obscured() -> CLLocationCoordinate2D {
        let latitude = self.latitude + Double.random(in: -0.05...0.05)
        let longitude = self.longitude + Double.random(in: -0.05...0.05)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
