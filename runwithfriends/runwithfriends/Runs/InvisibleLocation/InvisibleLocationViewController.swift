//
//  InvisibleLocationViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 29/2/24.
//

import UIKit
import CoreLocation
import Combine

/// TODO:
/// - It should ask for authorization before presenting waiting / running [ DONE ]
/// - It should only present waiting / running if authorized [ DONE ]
/// - It should start updating location once authorized [ DONE ]
/// - It should update waiting room pins [ DONE ]


class InvisibleLocationViewController: UIViewController {
    
    private var runManager: RunManager? {
        didSet {
            runManager?.$runStage
                .sink { [weak self] runStage in
                guard let self else { return }
                switch runStage {
                case .runEnd:
                    print("stopped updating location")
                    locationManager.stopUpdatingLocation()
                    cancellables.removeAll()
                default:
                    break
                }
            }.store(in: &cancellables)
        }
    }
    private let userData: UserData
    
    // Location
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    
    private var cancellables = Set<AnyCancellable>()

    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit invisible location vc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
    
    // Immediately show the next VC depending on the run
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // TODO for public runs
    private func presentWaitingVC(with location: CLLocationCoordinate2D) {
//        let waitingVC = WaitingRoomViewController(with: runManager, and: location)
//        waitingVC.modalPresentationStyle = .overFullScreen
//        present(waitingVC, animated: true)
    }
}

extension InvisibleLocationViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = manager.location {
                // TODO: Deal with flow for public runs
                print("Location authorized, setting user location")
                let soloRun = Run(run_id: UUID(), start_date: Int((Date() + 6).timeIntervalSince1970), end_date: Int((Date() + 906).timeIntervalSince1970), type: .solo, runners: [])
                self.runManager = RunManager(with: soloRun, and: userData)
                guard let runManager else { return }
                let runningVC = RunningViewController(with: runManager)
                runningVC.modalPresentationStyle = .overFullScreen
                present(runningVC, animated: true)
                print("started updating location")
                locationManager.startUpdatingLocation()
            }
        case .notDetermined:
            print("Location not authorized yet, just wait.")
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location permission denied or restricted")
            self.dismiss(animated: false) {
                guard let rootVC = UIApplication.shared.firstKeyWindow?.rootViewController else { return }
                let alert = UIAlertController.Oops(title: "Oops.", subtitle: "Enable location in iPhone settings\n\niPhone Settings > RunFriends > Location > While Using the App.")
                rootVC.present(alert, animated: true)
            }
        default:
            self.dismiss(animated: false)
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let runManager,
              let currentLocation = locations.last,
              currentLocation.timestamp >= runManager.run.start_date.getDate() else { return }
        
        if let lastLocation {
            runManager.sessionDistance += currentLocation.distance(from: lastLocation)
            print("location updated \(runManager.sessionDistance)")
        }
        
        self.lastLocation = currentLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failing \(error)")
    }
}
