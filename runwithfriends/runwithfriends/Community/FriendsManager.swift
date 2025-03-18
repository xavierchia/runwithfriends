//
//  FriendsManager.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 11/2/25.
//

import Foundation
import WidgetKit

struct FriendProgress: Codable {
    let user_id: UUID
    let username: String
    let steps: Int
}

class FriendsManager {
    static let shared = FriendsManager()
    private let defaults = UserDefaults(suiteName: "group.com.wholesomeapps.runwithfriends")
    private let friendsKey = "friendsProgress"
    
    private init() {}
    
    func updateFriends(_ friends: [FriendProgress]) {
        guard let defaults = defaults else { return }
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
    
    func getFriends() -> [FriendProgress] {
        guard let defaults = defaults else { return [] }
        
        if let data = defaults.data(forKey: friendsKey) {
            do {
                let friends = try JSONDecoder().decode([FriendProgress].self, from: data)
                return friends
            } catch {
                print("Failed to decode friends data: \(error)")
                return []
            }
        }
        
        return []
    }
}
