//
//  AuthManager.swift
//  runwithfriends
//
//  Created by xavier chia on 20/12/23.
//

import Foundation
import Supabase

enum SessionError: Error {
    case expired
}

class Supabase {
    static let shared = Supabase()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://yfzsopmnnvlbezldkstu.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmenNvcG1ubnZsYmV6bGRrc3R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDMwMzA0MTgsImV4cCI6MjAxODYwNjQxOH0.hlFyXx9YazvPAOqeTtRc9WSuhwntVnGPd-OUBBVRGD8")
    
    func upsert(steps: Int) async {
        do {
            let session = try KeychainManager.shared.getSession()
            let userId = session.userId
            let dateString = Date().getDateString()
            let step = Step(user_id: userId, date: dateString, steps: steps)
            
            try await client
                .from("steps")
                .upsert(step)
                .execute()
            print("upserted user data")
        } catch {
            print("failed to upsert steps \(error)")
        }
    }
    
    func setSessionIfNeeded() async {
        do {
            let session = try await client.auth.session
            if session.expiresIn < 86400 {
                throw SessionError.expired
            }
        } catch let noSessionError {
            print("No session, let's make one! \(noSessionError)")
            do {
                let session = try KeychainManager.shared.getSession()
                print(session)
                let newSession = try await client.auth.refreshSession(refreshToken: session.refreshToken)
                try KeychainManager.shared.saveSession(session: newSession)
            } catch let setSessionError {
                print("Failed to set session... \(setSessionError)")
            }
        }
    }
}

struct Step: Codable {
    let user_id: UUID
    let date: String
    let steps: Int
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
