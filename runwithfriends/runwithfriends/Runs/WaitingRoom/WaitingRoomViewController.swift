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
    
    // Location
    private let locationManager = CLLocationManager()
    private var pinsSet = false
    // coordinates for the The Panathenaic Stadium, where the first Olympic games were held
    private let defaultLocation = CLLocationCoordinate2D(latitude: 37.969, longitude: 23.741)
    
    // Run
    private let runSession: RunSession
    
    // UI
    private let mapView = MKMapView()
    private let bottomRow: BottomRow
    
    private var cancellables = Set<AnyCancellable>()
    
    init(with cellData: JoinRunData) {
        self.bottomRow = BottomRow(cellData: cellData)
        self.runSession = RunSession(runStartDate: cellData.date)
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
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        if locationManager.authorizationStatus == .notDetermined {
            print("Authorization status not determined, requesting authorization")
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("Authorization permitted, requesting location")
            locationManager.requestLocation()
        }
    }
    
    private func setupRunSession() {
        runSession.$runStage.sink { [weak self] runStage in
            guard let self else { return }
            switch runStage {
            case .waitingRunStart, .oneHourToRunStart:
                bottomRow.runStage = runStage
            case .fiveSecondsToRunStart:
                presentRunningVC()
            default:
                break
            }
        }.store(in: &cancellables)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
        mapView.mapType = .satelliteFlyover
        mapView.overrideUserInterfaceStyle = .dark
        view.insertSubview(mapView, belowSubview: bottomRow)
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
        pinsSet = true
        
        let obscuredCoordinate = coordinate.obscured()
        // Handle location update
        // Bigger span zooms out more
        let span = MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
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
    
    private func setupWaitingRoomTitle() {
        let waitingRoomTitle = UILabel()
        waitingRoomTitle.text = "Waiting Room"
        waitingRoomTitle.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        waitingRoomTitle.textColor = .white
        waitingRoomTitle.textAlignment = .center
        waitingRoomTitle.backgroundColor = .clear
        view.addSubview(waitingRoomTitle)
        waitingRoomTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waitingRoomTitle.widthAnchor.constraint(equalToConstant: 190),
            waitingRoomTitle.heightAnchor.constraint(equalToConstant: 28),
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
        closeButton.tintColor = .white

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
        let runningVC = RunningViewController(with: runSession)
        runningVC.modalPresentationStyle = .overFullScreen
        
        self.present(runningVC, animated: true)
    }
    
    @objc private func pop() {
        self.navigationController?.popViewController(animated: true)
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
            locationManager.stopUpdatingLocation()
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
