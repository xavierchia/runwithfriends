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
    var pinsSet = false
    
    // coordinates for the The Panathenaic Stadium, where the first Olympic games were held
    let defaultLocation = CLLocationCoordinate2D(latitude: 37.969, longitude: 23.741)
    
    init(with cellData: RunCellData) {
        bottomRow = BottomRow(cellData: cellData)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupLocationManager()
        setupBottomRow()
        setupMapView()
        setupCountdownTimer()
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
        pinsSet = true
        
        let obscuredCoordinate = coordinate.obscured()
        // Handle location update
        let span = MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
        let region = MKCoordinateRegion(center: obscuredCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🇸🇬"))
        newPin.coordinate = obscuredCoordinate
        newPin.title = UserData.shared.getUsername()
        mapView.addAnnotation(newPin)
                
        let chinaPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🇨🇳"))
        chinaPin.coordinate = CLLocationCoordinate2D(latitude: 39.9, longitude: 116.3)
        chinaPin.title = "Xiao Ming"
        mapView.addAnnotation(chinaPin)
        
        let vietPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🇻🇳"))
        vietPin.coordinate = CLLocationCoordinate2D(latitude: 10.8, longitude: 106.6)
        vietPin.title = "Phuong"
        mapView.addAnnotation(vietPin)
        
        let thaiPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🇹🇭"))
        thaiPin.coordinate = CLLocationCoordinate2D(latitude: 13.75, longitude: 100.5)
        thaiPin.title = "Pang"
        mapView.addAnnotation(thaiPin)
        
        let philPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🇵🇭"))
        philPin.coordinate = CLLocationCoordinate2D(latitude: 14.59, longitude: 120.98)
        philPin.title = "Kurt"
        mapView.addAnnotation(philPin)
    }
    
    private func setupCountdownTimer() {
        let countdownTimer = UILabel()
        countdownTimer.text = "Countdown: 5:00"
        countdownTimer.font = UIFont.systemFont(ofSize: countdownTimer.font.pointSize, weight: .bold)
        countdownTimer.textAlignment = .center
        countdownTimer.backgroundColor = .black
        countdownTimer.layer.cornerRadius = 10
        countdownTimer.layer.masksToBounds = true
        view.addSubview(countdownTimer)
        countdownTimer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countdownTimer.widthAnchor.constraint(equalToConstant: 170),
            countdownTimer.heightAnchor.constraint(equalToConstant: 40),
            countdownTimer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownTimer.bottomAnchor.constraint(equalTo: bottomRow.topAnchor, constant: -20)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        countdownTimer.addGestureRecognizer(tap)
        countdownTimer.isUserInteractionEnabled = true
    }
    
    @objc private func tapFunction() {
        print("tapped")
        let runningVC = RunningViewController()
        runningVC.modalPresentationStyle = .overFullScreen
        
        self.present(runningVC, animated: true)
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
        if pinsSet == false,
           let location = manager.location {
            print("Getting location passed")
            setMapRegion(with: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if pinsSet == false {
            print("Getting location failed")
            setMapRegion(with: defaultLocation)
        }
    }
}

extension WaitingRoomViewController: BottomRowProtocol {
    func leaveButtonPressed() {
        self.navigationController?.popViewController(animated: true)
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
