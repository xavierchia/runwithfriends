//
//  WaitingRoomViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 10/11/23.
//

import UIKit
import MapKit
import CoreLocation
import HealthKit

class CommunityViewController: UIViewController, MKMapViewDelegate {
    // database
    private let supabase = Supabase.shared.client.database
    private let userData: UserData
    private let healthStore = HKHealthStore()
    
    // Waiting room pins
    private var pinsSet = false
    private var coordinates = [CLLocationCoordinate2D]()
    
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
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // set map region
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.71588675681417, longitude: -74.01905943032843)
        let span = MKCoordinateSpan(latitudeDelta: 0.3298624346496055, longitudeDelta: 0.2226401886051832)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    private func setupUI() {
        setupMapView()
        addPath()
        addAnnotations()
        
        setupWaitingRoomTitle()
        setupUserDistance()
    }
    
    // MARK: Setup Map
    private func setupMapView() {
        // setup map
        mapView.mapType = .satelliteFlyover
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
        // put user on map
        let stepsQuantityType: Set = [HKQuantityType.quantityType(forIdentifier: .stepCount)!]
        healthStore.requestAuthorization(toShare: [], read: stepsQuantityType) { result, error in
            self.getSteps(from: Date.startOfWeek()) { [self] userSteps in
                var steps = 0.0
                var lastCoordinate = CLLocation(latitude: coordinates.first!.latitude, longitude: coordinates.first!.longitude)
                for coordinate in coordinates {
                    let currentCoordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let nextDistance = currentCoordinate.distance(from: lastCoordinate)
                    steps += nextDistance / 0.7
                    
                    if steps >= userSteps {
                        let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "😈"))
                        newPin.coordinate = lastCoordinate.coordinate
                        newPin.title = "xavier"
                        self.mapView.addAnnotation(newPin)
                        break
                    }
                    
                    lastCoordinate = currentCoordinate
                }
            }
        }
        
        // add ending flag
        guard let lastCoordinate = coordinates.last else { return }
        let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "🏁"))
        newPin.coordinate = lastCoordinate
        self.mapView.addAnnotation(newPin)
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
        let weekSteps = UILabel()
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
        
        let daySteps = UILabel()
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
        
        getSteps(from: Date.startOfWeek()) { steps in
            weekSteps.text = "Week: \(Int(steps).withCommas())"
        }
        
        getSteps(from: Date.startOfDay()) { steps in
            daySteps.text = "Day: \(Int(steps).withCommas())"
        }
        
    }

}

// MARK: Healthkit utilities
extension CommunityViewController {
    private func getSteps(from startDate: Date, completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startDate = startDate
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    completion(0.0)
                }
                return
            }
            DispatchQueue.main.async {
                completion(sum.doubleValue(for: HKUnit.count()))
            }
        }
        healthStore.execute(query)
    }
}
