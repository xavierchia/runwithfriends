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
    
    private func setupTabs() {
        setDark()

        let communityVC = CommunityViewController(userData: userData)
        communityVC.tabBarItem.title = "Community"
        communityVC.tabBarItem.image = UIImage(systemName: "globe.europe.africa")
        communityVC.tabBarItem.selectedImage = UIImage(systemName: "globe.europe.africa.fill")
        
        let profileVC = ProfileViewController(with: userData)
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem.title = "Profile"
        profileNav.tabBarItem.image = UIImage(systemName: "person")
        profileNav.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
        
        setViewControllers([communityVC, profileNav], animated: false)
        self.selectedIndex = 0
        // for testing
//        self.selectedIndex = 1
    }
    
    private func setDark() {
        UITabBar.appearance().unselectedItemTintColor = .gray

        self.tabBar.backgroundColor = .black
        self.tabBar.barTintColor = .black
        self.tabBar.tintColor = .cream
        self.tabBar.isTranslucent = false
    }
}
