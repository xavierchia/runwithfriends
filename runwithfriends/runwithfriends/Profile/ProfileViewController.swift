//
//  ProfileViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 6/11/23.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = UserData.shared.getUsername(withPrefix: true)
    }
    
    // MARK: SetupUI
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}
