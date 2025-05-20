//
//  GraphViewController.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 19/5/25.
//

import UIKit

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
            let steps = await StepCounter.shared.getSteps12Weeks()
            print(steps)
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
