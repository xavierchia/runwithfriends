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
    
    func getAuthenticatedClient() async throws -> SupabaseClient {
        
        // Get tokens from keychain
        let accessToken = try KeychainManager.shared.getAccessToken()
        let refreshToken = try KeychainManager.shared.getRefreshToken()
        
        // Set the session
        try await client.auth.setSession(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        
        return client
    }
    
    func upsert(steps: Int) async {
        do {
            let client = try await getAuthenticatedClient()
            let user = try await client.auth.session.user
            let walk = Walk(last_update: Date(), day_steps: steps)
            
            try await client.database.from("walks")
                .upsert(walk)
                .eq("user_id", value: user.id)
                .execute()
        } catch {
            print("failed to upsert steps \(error)")
        }
    }
    
//    func getSteps() async -> [Walker] {
//        do {
//            let client = try await getAuthenticatedClient()
//            let user = try await client.auth.session.user
//            let walk = Walk(last_update: Date(), day_steps: steps)
//            
//            try await client.database.from("walks")
//                .upsert(walk)
//                .eq("user_id", value: user.id)
//                .execute()
//        } catch {
//            print("failed to upsert steps \(error)")
//        }
//        
//        
//        do {
//            let year_week = Date.YearAndWeek()
//            var walkers: [Walker] = try await Supabase.shared.client.database
//                .rpc("get_user_steps", params: ["year_week_param": year_week])
//                .select()
//                .execute()
//                .value
//            
//            walkers.removeAll { walker in
//                walker.user_id == user.user_id
//            }
//            
//            // Side effect: Update friends data in shared defaults
//            let friends = walkers.map { FriendProgress(username: $0.username, steps: $0.steps) }
//            FriendsManager.shared.updateFriends(friends)
//            
//            return walkers
//        } catch {
//            print("failed to get walkers \(error)")
//            return []
//        }
//    }
}


struct Walk: Codable {
    let last_update: Date
    let day_steps: Int
}
