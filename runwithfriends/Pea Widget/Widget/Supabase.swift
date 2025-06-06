//
//  AuthManager.swift
//  runwithfriends
//
//  Created by xavier chia on 20/12/23.
//

import Foundation
import Supabase
import SharedCode

enum SessionError: Error {
    case expired
    case unsynced
}

class Supabase {
    static let shared = Supabase()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://yfzsopmnnvlbezldkstu.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmenNvcG1ubnZsYmV6bGRrc3R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDMwMzA0MTgsImV4cCI6MjAxODYwNjQxOH0.hlFyXx9YazvPAOqeTtRc9WSuhwntVnGPd-OUBBVRGD8")
    
    func upsert(steps: Int) async {
        do {
            let session = try KeychainManager.shared.getSession()
            let userId = session.user.id
            let dateString = Date().getDateString()
            let step = Step(user_id: userId, date: dateString, steps: steps)
            
            try await client
                .from("steps")
                .upsert(step)
                .execute()
            print("upserted steps")
        } catch {
            print("failed to upsert steps \(error)")
        }
    }
    
    func setSessionIfNeeded() async {
        do {
            let authSession = try await client.auth.session
            let keychainSession = try KeychainManager.shared.getSession()
            
            if authSession.accessToken != keychainSession.accessToken ||
                authSession.refreshToken != keychainSession.refreshToken {
                throw SessionError.unsynced
            }
            
            if authSession.expiresIn < 86400 {
                throw SessionError.expired
            }
            print("there is a session")
        } catch let noSessionError {
            print("No session, let's make one! \(noSessionError)")
            do {
                let session = try KeychainManager.shared.getSession()
                let newSession = try await client.auth.refreshSession(refreshToken: session.refreshToken)
                KeychainManager.shared.saveSession(session: newSession)
            } catch let setSessionError {
                print("Failed to set session... \(setSessionError)")
            }
        }
    }
    
    func getFollowingUsers() async -> [PeaUser] {
        do {
            let session = try KeychainManager.shared.getSession()
            let userId = session.user.id
            let following: [PeaUser] = try await Supabase.shared.client
                .rpc("get_following_users", params: ["follower_id": userId.uuidString])
                .execute()
                .value
            
            let currentFollowing = following.filter { followingUser in
                guard let weekDate = followingUser.weekDate else { return false }
                return weekDate == Date.startOfWeek()
            }
            
            return currentFollowing
        } catch {
            print("unable to get following users \(error)")
            return []
        }
    }
}
