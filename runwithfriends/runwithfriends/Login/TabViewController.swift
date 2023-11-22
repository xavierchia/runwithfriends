//
//  TabControllerViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    func setupTabs() {
        let runsVC = RunsViewController()
        let runsNav = UINavigationController(rootViewController: runsVC)
        runsNav.tabBarItem.title = "Runs"
        runsNav.tabBarItem.image = UIImage(systemName: "figure.run.circle")
        runsNav.tabBarItem.selectedImage = UIImage(systemName: "figure.run.circle.fill")
        
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem.title = "Profile"
        profileNav.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        profileNav.tabBarItem.selectedImage = UIImage(systemName: "person.crop.circle.fill")
        
        setViewControllers([runsNav, profileNav], animated: false)
        
        // xxavier temp select for testing
        self.selectedIndex = 0
    }
}
