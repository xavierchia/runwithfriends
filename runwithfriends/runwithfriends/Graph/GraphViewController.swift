//
//  GraphViewController.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 19/5/25.
//

import UIKit
import SwiftUI

class GraphViewController: UIViewController {
    
    private let userData: UserData
    private var hostingController: UIHostingController<StepsGraph>?
        
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupStepsGraph()
        
        view.backgroundColor = .baseBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data when view appears (in case user switched from other tabs)
        refreshStepsGraph()
    }

    private func setupNavigationController() {
        self.navigationItem.title = "Graphs"
        navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupStepsGraph() {
        // Use dummy data in simulator for testing
        #if targetEnvironment(simulator)
        let stepsGraph = StepsGraph(useDummyData: true)
        #else
        let stepsGraph = StepsGraph(useDummyData: false)
        #endif
        
        let controller = UIHostingController(rootView: stepsGraph)
        
        // Store reference for potential refresh calls
        self.hostingController = controller
        
        guard let stepsGraphView = controller.view else { return }
        
        // Add to view hierarchy
        addChild(controller)
        view.addSubview(stepsGraphView)
        controller.didMove(toParent: self)
        
        // Setup constraints
        stepsGraphView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepsGraphView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stepsGraphView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stepsGraphView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stepsGraphView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func refreshStepsGraph() {
        // Refresh the current mode's data when view appears
        if let hostingController = hostingController {
            hostingController.rootView.refreshCurrentMode()
        }
    }
}
