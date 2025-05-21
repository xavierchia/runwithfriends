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
        
        view.backgroundColor = .baseBackground
        
        Task {
            let dateSteps = await GraphMachine.shared.getSteps12Weeks()
            
            // for testing
//            let calendar = Calendar.current
//            let dateSteps = [
//                DateSteps(date: calendar.date(byAdding: .day, value: -21, to: Date())!, steps: 50000),
//                DateSteps(date: calendar.date(byAdding: .day, value: -14, to: Date())!, steps: 50000),
//                DateSteps(date: calendar.date(byAdding: .day, value: -7, to: Date())!, steps: 50000),
//                DateSteps(date: Date(), steps: 120000)
//            ]
            
            let controller = UIHostingController(rootView: StepsGraph(dateSteps: dateSteps))
            guard let stepsGraphView = controller.view else { return }
            
            view.addSubview(stepsGraphView)
            stepsGraphView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stepsGraphView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                stepsGraphView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                stepsGraphView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                stepsGraphView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
        }
    }

    private func setupNavigationController() {
        self.navigationItem.title = "Graphs"
        navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}
