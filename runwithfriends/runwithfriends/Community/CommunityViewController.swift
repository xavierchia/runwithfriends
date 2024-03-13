//
//  WaitingRoomViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 10/11/23.
//

import UIKit
import MapKit
import CoreLocation

class CommunityViewController: UIViewController {
    // database
    private let supabase = Supabase.shared.client.database
    private let userData: UserData
    
    // Waiting room pins
    private var pinsSet = false

    // UI
    private let mapView = MKMapView()
        
    init(userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLocation()
    }
    
    // MARK: Setup UI
    private func setupUI() {
        setupMapView()
        setupWaitingRoomTitle()
    }
    
    // MARK: Setup location manager
    private func setupMapView() {
        mapView.mapType = .satellite
        view.addSubview(mapView)
        mapView.delegate = self
//        view.insertSubview(mapView, belowSubview: bottomRow)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
                
        mapView.register(EmojiAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    private func updateLocation() {
        let startOfWeek = Date.startOfWeekEpochTime()
        Task {
            do {
                let runners: [Runner] = try await supabase
                    .rpc("get_runners_after_date", params: ["input_time": Int(startOfWeek)])
                    .select()
                    .execute()
                    .value
                guard let firstRunner = runners.first else { return }
                let focusRunner = runners.first { runner in
                    runner.user_id == userData.user.user_id
                } ?? firstRunner
                let focusRunnerCoordinate = CLLocationCoordinate2D(latitude: focusRunner.latitude, longitude: focusRunner.longitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: focusRunnerCoordinate, span: span)
                mapView.setRegion(region, animated: true)
                let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: focusRunner.emoji))
                newPin.coordinate = focusRunnerCoordinate
                newPin.title = "\(focusRunner.username) \(focusRunner.distance.valueKM)"
                mapView.addAnnotation(newPin)
                
                for otherRunner in runners {
                    guard otherRunner.user_id != focusRunner.user_id else { continue }
                    let runnerPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: otherRunner.emoji))
                    runnerPin.coordinate = CLLocationCoordinate2D(
                        latitude: otherRunner.latitude,
                        longitude: otherRunner.longitude
                    )
                    runnerPin.title = "\(otherRunner.username) \(otherRunner.distance.valueKM)"
                    mapView.addAnnotation(runnerPin)
                }

            } catch {
                print("cannot get runners for community tab \(error)")
            }
        }
    }
    
    private func setupWaitingRoomTitle() {
        let waitingRoomTitle = UILabel()
        waitingRoomTitle.text = "This Week"
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
    }
}

extension CommunityViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.region.span.longitudeDelta > 1 && mapView.region.span.latitudeDelta > 1 {
            mapView.mapType = .hybridFlyover
        } else {
            mapView.mapType = .satelliteFlyover
        }
    }
}
