//
//  WaitingRoomViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 10/11/23.
//

import UIKit
import MapKit
import SharedCode

class CommunityViewController: UIViewController {
    // database
    private let userData: UserData
    private let stepCounter = StepCounter.shared
    
    // UI
    private let mapView = PeaMapView()
    
    private let waitingRoomTitle = UILabel()
    private let stepsTitle = UIImageView()
    private let weekSteps = UILabel()
    private let daySteps = UILabel()
    private let zoomButton = UIButton()
    
    init(userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.peaMapViewDelegate = self
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSteps), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        waitingRoomTitle.text = MarathonData.getCurrentMarathon().title
        updateSteps()
        mapView.setMapRegion()
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
    
    @objc private func updateSteps() {
        print("updating view: annotations, labels")
        
        Task {
            let result = await stepCounter.getStepsForWeek()
            let weekSteps = result.reduce(0) { $0 + $1.steps }
            
            let daySteps = result.first { dailyStep in
                dailyStep.date == Date.startOfToday()
            }?.steps ?? 0
            
            await MainActor.run {
                self.userData.user.week_date = Date.startOfWeek().getDateString()
                self.userData.user.setDayStepsAndDate(Int(daySteps))
                self.userData.user.week_steps = Int(weekSteps)
                
                self.weekSteps.text = "Week: \(Int(weekSteps).withCommas())"
                self.daySteps.text = "Today: \(Int(daySteps).withCommas())"
            }
            
            userData.updateStepsIfNeeded(dailySteps: result)
            var pubs = await userData.getFollowingUsers(currentWeekOnly: true)
            let user = userData.user
            pubs.append(user)
            
            FriendsManager.shared.updateFriends(pubs)
            
            await MainActor.run {
                mapView.removeAnnotations(mapView.annotations)
                mapView.addStartAndEnd()
                mapView.addUserAnnotation(allUsers: pubs, currentUser: userData.user)
            }
        }
    }
    
    private func setupUI() {
        setupMapView()
        mapView.addPath()
        
        setupWaitingRoomTitle()
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
    
    private func setupZoomButton() {
        zoomButton.setTitle("Zoom In", for: .normal)
        zoomButton.titleLabel?.font = UIFont.KefirBold(size: 14)
        zoomButton.titleLabel?.textAlignment = .right
        zoomButton.setTitleColor(.cream, for: .normal)
        zoomButton.backgroundColor = .clear
        view.addSubview(zoomButton)
        zoomButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            zoomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            zoomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
        zoomButton.addTarget(self, action: #selector(zoomToUser), for: .touchUpInside)
    }
    
    @objc private func zoomToUser() {
        mapView.zoomInOrOut(currentUserId: userData.user.user_id.uuidString)
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
            stepsTitle.topAnchor.constraint(equalTo: waitingRoomTitle.bottomAnchor, constant: 10),
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
            daySteps.heightAnchor.constraint(equalToConstant: 30),
            daySteps.topAnchor.constraint(equalTo: waitingRoomTitle.bottomAnchor, constant: 32),
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
            weekSteps.heightAnchor.constraint(equalToConstant: 30),
            weekSteps.topAnchor.constraint(equalTo: waitingRoomTitle.bottomAnchor, constant: 52),
        ])
    }
}

extension CommunityViewController: PeaMapViewDelegate {
    func updateZoomLabel(labelString: String) {
        zoomButton.setTitle(labelString, for: .normal)
    }
    
    func annotationViewSelected(_ annotationView: MKAnnotationView) {

    }
}
