//
//  AuthManager.swift
//  runwithfriends
//
//  Created by xavier chia on 20/12/23.
//

import Foundation
import Supabase

class Supabase {
    static let shared = Supabase()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://yfzsopmnnvlbezldkstu.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmenNvcG1ubnZsYmV6bGRrc3R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDMwMzA0MTgsImV4cCI6MjAxODYwNjQxOH0.hlFyXx9YazvPAOqeTtRc9WSuhwntVnGPd-OUBBVRGD8")
    
    func upsert(steps: Int) async {
        do {
            let userId = try KeychainManager.shared.getUserIdToken()
            let dateString = Date().getDateString()
            let walk = Walk(user_id: userId, date: dateString, steps: steps)
            
            try await client
                .from("steps")
                .upsert(walk)
                .execute()
            print("upserted user data")
        } catch {
            print("failed to upsert steps \(error)")
        }
    }
}


struct Walk: Codable {
    let user_id: UUID
    let date: String
    let steps: Int
}

struct Walker: Codable {
    let user_id: UUID
    let username: String
    let emoji: String
    var walk: Walker.Walk
    
    struct Walk: Codable {
        var day_steps: Int
        var latitude: Double
        var longitude: Double
    }
    
    private enum CodingKeys: String, CodingKey {
        case user_id
        case username
        case emoji
        case walk = "walks"
    }
}

struct FriendProgress: Codable {
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
        } catch {
            print("Failed to save friends data: \(error)")
        }
    }
}
