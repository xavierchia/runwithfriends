//
//  File.swift
//  SharedCode
//
//  Created by Xavier Chia PY on 25/3/25.
//

import Foundation

public struct PeaDefaults {
    public static let shared = UserDefaults(suiteName: PeaDefaults.identifier)
    public static let identifier = "group.com.wholesomeapps.runwithfriends"
}

public struct UserDefaultsKey {
    // true false
    public static let hasSearchedFollowing = "hasSearchedFollowing"
    public static let isOnboardingComplete = "isOnboardingComplete"
    
    // last settings string
    public static let graphChartMode = "graphChartMode"
    
    // data
    public static let friendsProgress = "friendsProgress"
}
