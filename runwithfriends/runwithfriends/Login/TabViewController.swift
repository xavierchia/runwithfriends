//
//  TabControllerViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit

class TabViewController: UITabBarController {
    
    let userData: UserData

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTabs() {
        let runsVC = RunsViewController(with: userData)
        let runsNav = UINavigationController(rootViewController: runsVC)
        runsNav.tabBarItem.title = "Runs"
        runsNav.tabBarItem.image = UIImage(systemName: "figure.run.circle")
        runsNav.tabBarItem.selectedImage = UIImage(systemName: "figure.run.circle")
        
        let profileVC = ProfileViewController(with: userData)
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem.title = "Profile"
        profileNav.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        profileNav.tabBarItem.selectedImage = UIImage(systemName: "person.crop.circle")
        
        setViewControllers([runsNav, profileNav], animated: false)
        
        self.selectedIndex = 0
        // for testing
//        self.selectedIndex = 1
    }
}
