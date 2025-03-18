//
//  WaitingRoomViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 10/11/23.
//

import UIKit
import MapKit

class CommunityViewController: UIViewController {
    // database
    private let userData: UserData
    private let stepCounter = StepCounter.shared
    
    // UI
    private let mapView = PeaMapView()
    private let stepsTitle = UIImageView()
    private let weekSteps = UILabel()
    private let daySteps = UILabel()
    
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
        
        // Request motion permission when view loads
        stepCounter.requestMotionPermission { authorized in
            if !authorized {
                // Handle the case where permission is denied
                DispatchQueue.main.async {
                    self.showMotionPermissionAlert()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateView()
    }
    
    private func showMotionPermissionAlert() {
        let alert = UIAlertController(
            title: "Motion Access Required",
            message: "Please enable motion and fitness access in Settings to track your steps.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func updateView() {
        print("updating view: region, annotations, labels")
        // set map region
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.71588675681417, longitude: -74.01905943032843)
        let span = MKCoordinateSpan(latitudeDelta: 0.3298624346496055, longitudeDelta: 0.2226401886051832)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapView.setRegion(region, animated: false)
        
        Task {
            let result = await stepCounter.getStepsForWeek()
            let weekSteps = result.reduce(0) { $0 + $1.steps }
            
            let daySteps = result.first { dailyStep in
                dailyStep.date == Date.startOfToday()
            }?.steps ?? 0
            
            await MainActor.run {
                self.userData.user.day_date = Date.startOfToday().getDateString()
                self.userData.user.week_date = Date.startOfWeek().getDateString()
                self.userData.user.day_steps = Int(daySteps)
                self.userData.user.week_steps = Int(weekSteps)
                
                self.weekSteps.text = "Week: \(Int(weekSteps).withCommas())"
                self.daySteps.text = "Today: \(Int(daySteps).withCommas())"
            }
            
            userData.updateStepsIfNeeded(dailySteps: result)
            let pubs = await userData.getPublicUsers()
            
            await MainActor.run {
                mapView.removeAnnotations(mapView.annotations)
                mapView.addStartAndEnd()
                mapView.addUserAnnotation(allUsers: pubs, currentUser: userData.user)
//                mapView.zoomToCurrentUserContext(currentUserId: userData.user.user_id.uuidString)
            }
        }
    }
    
    private func setupUI() {
        setupMapView()
        mapView.addPath()
        
        setupWaitingRoomTitle()
        setupPodTitle()
        setupUserDistance()
        setupZoomButton()
    }
    
    // MARK: Setup Map
    private func setupMapView() {
        // setup map
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: Setup UI
    private func setupWaitingRoomTitle() {
        let waitingRoomTitle = UILabel()
        waitingRoomTitle.text = "New York\nMarathon\nin steps"
        waitingRoomTitle.font = UIFont.KefirBold(size: 28)
        waitingRoomTitle.numberOfLines = 0
        waitingRoomTitle.textAlignment = .left
        waitingRoomTitle.textColor = .cream
        waitingRoomTitle.backgroundColor = .clear
        view.addSubview(waitingRoomTitle)
        waitingRoomTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waitingRoomTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            waitingRoomTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
        ])
    }
    
    private func setupPodTitle() {
        let podTitle = UIButton()
        podTitle.setTitle("Pea Pods", for: .normal)
        podTitle.titleLabel?.font = UIFont.KefirBold(size: 14)
        podTitle.titleLabel?.textAlignment = .right
        podTitle.setTitleColor(.cream, for: .normal)
        podTitle.backgroundColor = .clear
        view.addSubview(podTitle)
        podTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            podTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            podTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
        ])
        
        podTitle.addTarget(self, action: #selector(podButtonPressed), for: .touchUpInside)
    }
    
    @objc private func podButtonPressed() {
        print("poddy")
        let vc = PodContainerViewController()
        present(vc, animated: true)
    }
    
    private func setupZoomButton() {
        let zoomTitle = UIButton()
        zoomTitle.setTitle("Zoom", for: .normal)
        zoomTitle.titleLabel?.font = UIFont.KefirBold(size: 14)
        zoomTitle.titleLabel?.textAlignment = .right
        zoomTitle.setTitleColor(.cream, for: .normal)
        zoomTitle.backgroundColor = .clear
        view.addSubview(zoomTitle)
        zoomTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            zoomTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            zoomTitle.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
        zoomTitle.addTarget(self, action: #selector(zoomToUser), for: .touchUpInside)
    }
    
    @objc private func zoomToUser() {
        mapView.zoomToCurrentUserContext(currentUserId: userData.user.user_id.uuidString)
    }
    
    private func setupUserDistance() {
        stepsTitle.image = UIImage(systemName: "figure.walk.motion")
        stepsTitle.tintColor = .cream
        stepsTitle.contentMode = .scaleAspectFit
        view.addSubview(stepsTitle)
        stepsTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepsTitle.widthAnchor.constraint(equalToConstant: 22),
            stepsTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stepsTitle.heightAnchor.constraint(equalToConstant: 22),
            stepsTitle.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
        ])
        
        weekSteps.font = UIFont.QuicksandMedium(size: 16)
        weekSteps.text = "Week: 0 steps"
        weekSteps.textAlignment = .left
        weekSteps.textColor = .cream
        weekSteps.backgroundColor = .clear
        view.addSubview(weekSteps)
        weekSteps.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weekSteps.widthAnchor.constraint(equalToConstant: view.frame.width),
            weekSteps.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            weekSteps.heightAnchor.constraint(equalToConstant: 40),
            weekSteps.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
        daySteps.font = UIFont.QuicksandMedium(size: 16)
        daySteps.text = "Today: 0 steps"
        daySteps.textAlignment = .left
        daySteps.textColor = .cream
        daySteps.backgroundColor = .clear
        view.addSubview(daySteps)
        daySteps.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daySteps.widthAnchor.constraint(equalToConstant: view.frame.width),
            daySteps.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            daySteps.heightAnchor.constraint(equalToConstant: 40),
            daySteps.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])
    }
}
