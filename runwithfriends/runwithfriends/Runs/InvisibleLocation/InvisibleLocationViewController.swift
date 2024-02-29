//
//  InvisibleLocationViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 29/2/24.
//

import UIKit

class InvisibleLocationViewController: UIViewController {
    
    private let runManager: RunManager

    init(with run: Run, and userData: UserData) {
        self.runManager = RunManager(with: run, and: userData)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let waitingRoomVC = WaitingRoomViewController(with: runManager)
        waitingRoomVC.modalPresentationStyle = .overFullScreen
        self.present(waitingRoomVC, animated: true)
    }
}
