//
//  FriendsManager.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 11/2/25.
//

import Foundation
import WidgetKit

class FriendsManager {
    static let shared = FriendsManager()
    private let friendsKey = "friendsProgress"
    
    private init() {}
    
    func updateFriends(_ friends: [User]) {
        guard let defaults = AppDelegate.appUserDefaults else { return }
        do {
            print("saved friends")
            let data = try JSONEncoder().encode(friends)
            defaults.set(data, forKey: friendsKey)
            defaults.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to save friends data: \(error)")
        }
    }
}
