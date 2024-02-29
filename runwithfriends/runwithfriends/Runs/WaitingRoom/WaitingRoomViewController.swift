//
//  WaitingRoomViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 10/11/23.
//

import UIKit
import MapKit
import CoreLocation
import Combine

class WaitingRoomViewController: UIViewController {
    // database
    private let supabase = Supabase.shared.client.database
    
    // Location
    private let locationManager = CLLocationManager()
    
    // Waiting room pins
    private var pinsSet = false
    // coordinates for the The Panathenaic Stadium, where the first Olympic games were held
    private let defaultLocation = CLLocationCoordinate2D(latitude: 37.969, longitude: 23.741)
    
    // Running room
    private var lastLocation: CLLocation?
    
    // init data
    private let runManager: RunManager
    
    // UI
    private let mapView = MKMapView()
    private let bottomRow: BottomRow
    
    private var cancellables = Set<AnyCancellable>()
    
    init(with runManager: RunManager) {
        self.bottomRow = BottomRow(with: runManager.run)
        self.runManager = runManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupRunSession()
        setupUI()
    }
    
    private func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        
        if locationManager.authorizationStatus == .notDetermined {
            print("Authorization status not determined, requesting authorization")
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("Authorization permitted, requesting location")
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setupRunSession() {
        runManager.$runStage
            .sink { [weak self] runStage in
            guard let self else { return }
            switch runStage {
            case .waitingRunStart, .oneHourToRunStart:
                bottomRow.runStage = runStage
            case .fiveSecondsToRunStart:
                presentRunningVC()
            case .runEnd:
                locationManager.stopUpdatingLocation()
            default:
                break
            }
        }.store(in: &cancellables)
        
        Task {
            // Upsert when joining a run, distance 0
            await runManager.upsertRunSession()
        }
    }
    
    // MARK: Setup UI
    private func setupUI() {
        setupBottomRow()
        setupMapView()
        setupWaitingRoomTitle()
        setupCloseButton()
    }
    
    private func setupBottomRow() {
        bottomRow.delegate = self
        view.addSubview(bottomRow)
        
        NSLayoutConstraint.activate([
            bottomRow.heightAnchor.constraint(equalToConstant: 80),
            bottomRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: Setup location manager
    private func setupMapView() {
        mapView.mapType = .hybridFlyover
        view.insertSubview(mapView, belowSubview: bottomRow)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
                
        mapView.register(EmojiAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    private func locationUpdated(with coordinate: CLLocationCoordinate2D) {
        let obscuredCoordinate = coordinate.obscured()
        setPins(with: obscuredCoordinate)
        runManager.userData.updateUserCoordinate(obscuredCoordinate: obscuredCoordinate)
    }
    
    private func setPins(with obscuredCoordinate: CLLocationCoordinate2D) {
        pinsSet = true
        
        // Handle location update
        // Bigger span zooms out more
        let span = MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
        let region = MKCoordinateRegion(center: obscuredCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🇸🇬"))
        newPin.coordinate = obscuredCoordinate
        newPin.title = runManager.userData.user.username
        mapView.addAnnotation(newPin)
        
        runManager.run.runners.forEach { runner in
            let runnerPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: runner.emoji))
            
            runnerPin.coordinate = CLLocationCoordinate2D(
                latitude: runner.latitude ?? defaultLocation.latitude,
                longitude: runner.longitude ?? defaultLocation.longitude
            )
            runnerPin.title = runner.username
            mapView.addAnnotation(runnerPin)
        }
    }
    
    private func setupWaitingRoomTitle() {
        guard let displayTime = runManager.run.start_date.getDate().getDisplayTime(padZero: false) else {
            return
        }

        let waitingRoomTitle = UILabel()
        waitingRoomTitle.text = "\(displayTime.time)\(displayTime.amOrPm.lowercased()) run"
        waitingRoomTitle.font = UIFont.KefirBold(size: 34)
        waitingRoomTitle.textColor = .cream
        waitingRoomTitle.textAlignment = .center
        waitingRoomTitle.backgroundColor = .clear
        view.addSubview(waitingRoomTitle)
        waitingRoomTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waitingRoomTitle.widthAnchor.constraint(equalToConstant: 250),
            waitingRoomTitle.heightAnchor.constraint(equalToConstant: 40),
            waitingRoomTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            waitingRoomTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentRunningVC))
        waitingRoomTitle.addGestureRecognizer(tap)
        waitingRoomTitle.isUserInteractionEnabled = true
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton()
        var config = UIImage.SymbolConfiguration(weight: .bold)
        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
        let pointConfig = UIImage.SymbolConfiguration(pointSize: 20)
        config = config.applying(largeConfig).applying(pointConfig)
        let closeButtonImage = UIImage(systemName: "xmark", withConfiguration: config)
        closeButton.setImage(closeButtonImage, for: .normal)
        closeButton.tintColor = .cream

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12)
        ])
        closeButton.addTarget(self, action: #selector(pop), for: .touchUpInside)
    }
    
    @objc private func presentRunningVC() {
        guard !(presentedViewController is RunningViewController) else {
            return
        }
        print("Presenting running vc")
        let runningVC = RunningViewController(with: runManager)
        runningVC.modalPresentationStyle = .overFullScreen
        
        self.present(runningVC, animated: true)
    }
    
    @objc private func pop() {
        Task {
            self.view.window?.rootViewController?.dismiss(animated: true)
            await runManager.leaveRun()
        }
    }
}

// MARK: CLLocationManagerDelegate
extension WaitingRoomViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            if let location = manager.location {
                print("Location authorized, setting user location")
                locationUpdated(with: location.coordinate)
                locationManager.startUpdatingLocation()
            }
        } else if manager.authorizationStatus == .notDetermined {
            print("Location not authorized yet, just wait.")
        } else {
            print("Did not authorize, setting default location")
            locationUpdated(with: defaultLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if pinsSet == false,
           let location = manager.location {
            print("Getting location passed")
            locationUpdated(with: location.coordinate)
        }
        
        guard let currentLocation = locations.last,
              currentLocation.timestamp >= runManager.run.start_date.getDate() else { return }
        
        if let lastLocation {
            runManager.totalDistance += currentLocation.distance(from: lastLocation)
            print("location updated \(runManager.totalDistance)")
        }
        
        self.lastLocation = currentLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if pinsSet == false {
            print("Getting location failed")
            locationUpdated(with: defaultLocation)
        }
    }
}

extension WaitingRoomViewController: BottomRowProtocol {
    func inviteButtonPressed() {
        print("invite friends")
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
