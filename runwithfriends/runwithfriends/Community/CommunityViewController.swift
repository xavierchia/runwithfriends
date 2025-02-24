//
//  WaitingRoomViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 10/11/23.
//

import UIKit
import MapKit

class CommunityViewController: UIViewController, MKMapViewDelegate {
    // database
    private let userData: UserData
    private let stepCounter = StepCounter.shared
    
    // Waiting room pins
    private var pinsSet = false
    private var coordinates = [CLLocationCoordinate2D]()
    
    // UI
    private let mapView = MKMapView()
    private let weekSteps = UILabel()
    let daySteps = UILabel()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateView()
    }
    
    @objc private func updateView() {
        print("updating view: region, annotations, labels")
        // set map region
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.71588675681417, longitude: -74.01905943032843)
        let span = MKCoordinateSpan(latitudeDelta: 0.3298624346496055, longitudeDelta: 0.2226401886051832)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapView.setRegion(region, animated: false)
        
        addAnnotations()
        
        updateSteps()
    }
    
    private func setupUI() {
        setupMapView()
        addPath()
        
        setupWaitingRoomTitle()
        setupUserDistance()
    }
    
    // MARK: Setup Map
    private func setupMapView() {
        // setup map
        mapView.mapType = .satelliteFlyover
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        mapView.register(EmojiAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    private func addPath() {
        // get current path coordinates
        if let audioFilePath = Bundle.main.path(forResource: "NYCMarathon", ofType: "gpx") {
            let parser = Parser()
            if let coordinates = parser.parseCoordinates(fromGpxFile: audioFilePath) {
                self.coordinates = coordinates
                
                let borderPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                borderPolyline.title = "border"
                mapView.addOverlay(borderPolyline)
                
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                polyline.title = "main"
                mapView.addOverlay(polyline)
            }
        }
    }
    
    private func addAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        // put user on map
        let walk = Walker.Walk(steps: 0, latitude: 0, longitude: 0)
        var userWalker = Walker(user_id: userData.user.user_id, username: userData.user.username, emoji: userData.user.emoji, walk: walk)
        
        stepCounter.getSteps(from: Date.startOfWeek()) { [self] userSteps in
            var steps = 0.0
            var lastCoordinate = CLLocation(latitude: coordinates.first!.latitude, longitude: coordinates.first!.longitude)
            for (index, coordinate) in coordinates.enumerated() {
                let currentCoordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let nextDistance = currentCoordinate.distance(from: lastCoordinate)
                steps += nextDistance / 0.7
                
                let isLastIndex = index == coordinates.count - 1
                if steps >= userSteps || isLastIndex  {
                    let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: userData.user.emoji), color: .lightAccent)
                    let userCoordinate = isLastIndex ? currentCoordinate.coordinate : lastCoordinate.coordinate
                    newPin.coordinate = userCoordinate
                    newPin.title = userData.user.username
                    newPin.identifier = "user"
                    self.mapView.addAnnotation(newPin)
                    
                    userWalker.walk.latitude = userCoordinate.latitude
                    userWalker.walk.longitude = userCoordinate.longitude
                    userWalker.walk.steps = Int(userSteps)
                    
                    self.userData.updateWalk(with: Int(userSteps), and: userCoordinate)
                    break
                }
                
                lastCoordinate = currentCoordinate
            }
        }
        
        Task {
            var walkers = await userData.getWalkers()
            walkers.append(userWalker)
            walkers.sort { lhs, rhs in
                lhs.walk.steps < rhs.walk.steps
            }
            
            let finalCoordinate = coordinates.last!
            print(finalCoordinate)
            var lastLongitude = 0.0
            var collisions = 1.0
            for (index, walker) in walkers.enumerated() {
                
                // Remove original user emoji that was placed so there's no duplicate
                if walker.user_id == userData.user.user_id {
                    if let selfAnnotation = mapView.annotations.first(where: { annotation in
                        let emojiAnnotation = annotation as? EmojiAnnotation
                        return emojiAnnotation?.identifier == "user"
                    }) {
                        mapView.removeAnnotation(selfAnnotation)
                    }
                }
                
                let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: walker.emoji))
                if index == walkers.count - 1 {
                    newPin.emojiImage = OriginalUIImage(emojiString: "👑")
                }
                if walker.username.lowercased() == "zombie" {
                    newPin.color = .red
                }
                if walker.user_id == userData.user.user_id {
                    newPin.color = .lightAccent
                }
                                
                if walker.walk.longitude == finalCoordinate.longitude && walker.walk.latitude == finalCoordinate.latitude {
                    newPin.coordinate = CLLocationCoordinate2D(latitude: walker.walk.latitude + 0.005 * collisions, longitude: walker.walk.longitude)
                    collisions += 1
                } else if walker.walk.longitude == lastLongitude {
                    newPin.coordinate = CLLocationCoordinate2D(latitude: walker.walk.latitude, longitude: walker.walk.longitude + 0.005 * collisions)
                    collisions += 1
                } else {
                    newPin.coordinate = CLLocationCoordinate2D(latitude: walker.walk.latitude, longitude: walker.walk.longitude)
                    collisions = 1
                }
                
                lastLongitude = walker.walk.longitude
                newPin.title = walker.username
                self.mapView.addAnnotation(newPin)
            }
        }
        
        guard let firstCoordinate = coordinates.first else { return }
        let startPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "⛩️"))
        startPin.coordinate = firstCoordinate
        self.mapView.addAnnotation(startPin)
        
        // add ending flag
        guard let lastCoordinate = coordinates.last else { return }
        let endPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🏁"))
        endPin.coordinate = lastCoordinate
        self.mapView.addAnnotation(endPin)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = overlay.title == "main" ? UIColor.accent : .cream
        renderer.lineWidth = overlay.title == "main" ? 5 : 7
        renderer.lineCap = .round
        return renderer
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
            waitingRoomTitle.heightAnchor.constraint(equalToConstant: 120),
            waitingRoomTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            waitingRoomTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupUserDistance() {
        weekSteps.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        weekSteps.text = "week"
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
        
        daySteps.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        daySteps.text = "Today: 300 steps"
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
    
    private func updateSteps() {
        stepCounter.getSteps(from: Date.startOfWeek()) { steps in
            self.weekSteps.text = "Week: \(Int(steps).withCommas())"
        }
        
        stepCounter.getSteps(from: Date.startOfDay()) { steps in
            self.daySteps.text = "Day: \(Int(steps).withCommas())"
        }
    }
}
