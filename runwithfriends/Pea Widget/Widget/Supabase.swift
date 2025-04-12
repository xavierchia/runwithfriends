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
            let session = try await client.auth.session
            if session.expiresIn < 86400 {
                throw SessionError.expired
            }
            print("there is a session")
        } catch let noSessionError {
            print("No session, let's make one! \(noSessionError)")
            do {
                let session = try KeychainManager.shared.getSession()
                print(session)
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
            
            return following
        } catch {
            print("unable to get following users \(error)")
            return []
        }
    }
}
