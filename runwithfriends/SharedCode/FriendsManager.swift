//
//  FriendsManager.swift
//  SharedCode
//
//  Created by Xavier Chia PY on 26/3/25.
//

import Foundation
import WidgetKit

struct SharedCodeUtilities {
    static let isWidget = Bundle.main.bundleIdentifier?.lowercased().contains("widget") ?? false
}

public struct FriendsManager {
    public static let shared = FriendsManager()
    private let defaults = PeaDefaults.shared
    private let friendsKey = "friendsProgress"
    
    private init() {}
    
    public func updateFriends(_ friends: [PeaUser]) {
        guard let defaults else { return }
        do {
            print("saved friends")
            let data = try JSONEncoder().encode(friends)
            defaults.set(data, forKey: friendsKey)
            defaults.synchronize()
            
            if SharedCodeUtilities.isWidget {
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("Failed to save friends data: \(error)")
        }
    }

    
    public func getFriends() -> [PeaUser] {
        guard let defaults = defaults else { return [] }
        
        if let data = defaults.data(forKey: friendsKey) {
            do {
                let friends = try JSONDecoder().decode([PeaUser].self, from: data)
                return friends
            } catch {
                print("Failed to decode friends data: \(error)")
                return []
            }
        }
        
        return []
    }
}
