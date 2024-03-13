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
    
    // Waiting room pins
    private var pinsSet = false
    
    // init data
    private let runManager: RunManager
    private let userLocation: CLLocationCoordinate2D
    
    // UI
    private let mapView = MKMapView()
    private let bottomRow: BottomRow
    
    private var cancellables = Set<AnyCancellable>()
    
    init(with runManager: RunManager, and location: CLLocationCoordinate2D) {
        self.bottomRow = BottomRow(with: runManager.run)
        self.runManager = runManager
        self.userLocation = location
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit waiting room vc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRunSession()
        setupUI()
        locationUpdated(with: self.userLocation)
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
        
        func setPins(with obscuredCoordinate: CLLocationCoordinate2D) {
            pinsSet = true
            
            // Handle location update
            // Bigger span zooms out more
            let span = MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
            let region = MKCoordinateRegion(center: obscuredCoordinate, span: span)
            mapView.setRegion(region, animated: true)
            let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: runManager.userData.user.emoji))
            newPin.coordinate = obscuredCoordinate
            newPin.title = runManager.userData.user.username
            mapView.addAnnotation(newPin)
            
            for runner in runManager.run.runners {
                let runnerPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: runner.emoji))
                guard let runnerLatitude = runner.latitude,
                      let runnerLongitude = runner.longitude else { continue }
                
                runnerPin.coordinate = CLLocationCoordinate2D(
                    latitude: runnerLatitude,
                    longitude: runnerLongitude
                )
                runnerPin.title = runner.username
                mapView.addAnnotation(runnerPin)
            }
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Task {
            self.view.window?.rootViewController?.dismiss(animated: true)
            await runManager.leaveRun()
        }
    }
}

extension WaitingRoomViewController: BottomRowProtocol {
    func inviteButtonPressed() {
        print("invite friends")
    }
}
