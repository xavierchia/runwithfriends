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

class CommunityViewController: UIViewController {
    // database
    private let supabase = Supabase.shared.client.database
    private let userData: UserData
    
    // Waiting room pins
    private var pinsSet = false
    private var userCoordinate = CLLocationCoordinate2D()
    
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
        let stepsQuantityType: Set = [HKQuantityType.quantityType(forIdentifier: .stepCount)!]

        Task {
            try await healthStore.requestAuthorization(toShare: [], read: stepsQuantityType)
            self.getTodaysSteps { steps in
                print(steps)
            }
        }
    }
    
    let healthStore = HKHealthStore()

    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        healthStore.execute(query)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let region = MKCoordinateRegion(center: userCoordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = overlay.title == "main" ? UIColor.accent : .cream
        renderer.lineWidth = overlay.title == "main" ? 5 : 7
        renderer.lineCap = .round
        return renderer
    }
    
    // MARK: Setup UI
    private func setupUI() {
        setupMapView()
        setupWaitingRoomTitle()
                
        if let audioFilePath = Bundle.main.path(forResource: "NYCMarathon", ofType: "gpx") {
            let parser = Parser()
            if let coordinates = parser.parseCoordinates(fromGpxFile: audioFilePath) {
                
                let borderPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                borderPolyline.title = "border"
                mapView.addOverlay(borderPolyline)
                
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                polyline.title = "main"
                mapView.addOverlay(polyline)
                
                userCoordinate = coordinates[15]
                let newPin = EmojiAnnotation(emojiImage: OriginalUIImage(emojiString: "😈"))
                newPin.coordinate = userCoordinate
                newPin.title = "xavier"
                mapView.addAnnotation(newPin)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                }
            }
        }
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
    
    private func setupWaitingRoomTitle() {
        let waitingRoomTitle = UILabel()
        waitingRoomTitle.text = "New York\nMarathon"
        waitingRoomTitle.font = UIFont.KefirBold(size: 28)
        waitingRoomTitle.numberOfLines = 0
        waitingRoomTitle.textAlignment = .left
        waitingRoomTitle.textColor = .cream
        waitingRoomTitle.backgroundColor = .clear
        view.addSubview(waitingRoomTitle)
        waitingRoomTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waitingRoomTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            waitingRoomTitle.heightAnchor.constraint(equalToConstant: 80),
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

public class BorderPathRenderer: MKOverlayPathRenderer {
    
    var polyline: MKPolyline
    var color: UIColor
    var showsBorder: Bool = false
    var borderColor: UIColor = .black
    
    public init(polyline: MKPolyline, color: UIColor) {
        self.polyline = polyline
        self.color = color
        
        super.init(overlay: polyline)
    }
    
    public init(polyline: MKPolyline, color: UIColor, showsBorder: Bool, borderColor: UIColor) {
        self.polyline = polyline
        self.color = color
        self.showsBorder = showsBorder
        self.borderColor = borderColor
        
        super.init(overlay: polyline)
    }
    
    public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let baseWidth: CGFloat = lineWidth / zoomScale
        
        if showsBorder {
            context.setLineWidth(baseWidth * 2)
            context.setLineJoin(CGLineJoin.round)
            context.setLineCap(CGLineCap.round)
            context.addPath(path)
            context.setStrokeColor(borderColor.cgColor)
            context.strokePath()
        }
        
        context.setLineWidth(baseWidth)
        context.addPath(path)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
        
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
    
    public override func createPath() {
        let path: CGMutablePath  = CGMutablePath()
        var pathIsEmpty: Bool = true
        
        for i in 0...self.polyline.pointCount - 1 {
            let point: CGPoint = self.point(for: self.polyline.points()[i])
            if pathIsEmpty {
                path.move(to: point)
                pathIsEmpty = false
            } else {
                path.addLine(to: point)
            }
        }
        self.path = path
    }
}
