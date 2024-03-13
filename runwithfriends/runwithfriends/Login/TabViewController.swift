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
    
    override var selectedViewController: UIViewController? {
        didSet {
            setTabColor()
        }
    }
    
    private func setupTabs() {
        UITabBar.appearance().unselectedItemTintColor = .gray

        let communityVC = CommunityViewController()
        communityVC.tabBarItem.title = "Community"
        communityVC.tabBarItem.image = UIImage(systemName: "globe.europe.africa")
        
        let runsVC = RunsViewController(with: userData)
        let runsNav = UINavigationController(rootViewController: runsVC)
        runsNav.tabBarItem.title = "Runs"
        runsNav.tabBarItem.image = UIImage(systemName: "figure.run")
        
        let distanceVC = DistanceViewController(with: userData)
        let distanceNav = UINavigationController(rootViewController: distanceVC)
        distanceNav.tabBarItem.title = "Milestones"
        distanceNav.tabBarItem.image = UIImage(systemName: "mountain.2")
        
        let profileVC = ProfileViewController(with: userData)
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem.title = "Profile"
        profileNav.tabBarItem.image = UIImage(systemName: "person")
        
        setViewControllers([communityVC, runsNav, distanceNav], animated: false)
        self.selectedIndex = 0
        // for testing
//        self.selectedIndex = 1
        
        setTabColor()
    }
    
    private func setTabColor() {
        if selectedViewController is CommunityViewController {
            setDark()
        } else {
            setLight()
        }
    }
    
    private func setDark() {
        self.tabBar.backgroundColor = .black
        self.tabBar.barTintColor = .black
        self.tabBar.tintColor = .cream
        self.tabBar.isTranslucent = true
    }
    
    private func setLight() {
        self.tabBar.backgroundColor = .cream
        self.tabBar.barTintColor = .cream
        self.tabBar.tintColor = .black
        self.tabBar.isTranslucent = true
    }
}
