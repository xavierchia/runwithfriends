//
//  UserData.swift
//  runwithfriends
//
//  Created by xavier chia on 7/11/23.
//
import Foundation
import CoreLocation
import Supabase
import SharedCode

class UserData {
    static let defaultUsername = "Pea"
    
    @MainActor
    var user: PeaUser {
        didSet {
            KeychainManager.shared.saveUser(user: user)
        }
    }
    
    private var lastServerSync: Date?
    private let minimumSyncInterval: TimeInterval = 60
    
    @MainActor
    init(user: PeaUser) {
        self.user = user
    }
    
    func updateStepsIfNeeded(dailySteps: [DailySteps]) {
        Task {
            if let lastSync = lastServerSync,
                Date().timeIntervalSince(lastSync) < minimumSyncInterval {
                 return
             }
             
             do {
                 let userId = await self.user.user_id
                 let steps = dailySteps.map { dailyStep in
                     Step(user_id: userId, date: dailyStep.date.getDateString(), steps: Int(dailyStep.steps))
                 }
                 
                 try await Supabase.shared.client.from("steps")
                     .upsert(steps)
                     .execute()
                 print("Synced steps with server")
                 lastServerSync = Date()
             } catch {
                 print("Failed to sync with server: \(error.localizedDescription)")
             }
        }
    }
    
    func getFollowingUsers() async -> [PeaUser] {
        do {
            let following: [PeaUser] = try await Supabase.shared.client
                .rpc("get_following_users", params: ["follower_id": user.user_id.uuidString])
                .execute()
                .value
            
            return following
        } catch {
            print("unable to get following users \(error)")
            return []
        }
    }
    
    func follow(userId: UUID) async {
        do {
            try await Supabase.shared.client
                .from("following")
                .insert(["follower": user.user_id.uuidString, "followed": userId.uuidString])
                .execute()
            
        } catch {
            print("could not follow user \(error)")
        }
    }
    
    func unfollow(userId: UUID) async {
        do {
            try await Supabase.shared.client
                .from("following")
                .delete()
                .eq("follower", value: user.user_id.uuidString)
                .eq("followed", value: userId.uuidString)
                .execute()            
        } catch {
            print("could not unfollow user \(error)")
        }
    }
    
    func getUser(searchId: Int) async -> PeaUser? {
        do {
            let peaUser: PeaUser = try await Supabase.shared.client
                .from("users")
                .select()
                .eq("search_id", value: searchId)
                .single()
                .execute()
                .value
            return peaUser
        } catch {
            print("can't get specific user")
        }
        return nil
    }
    
    // MARK: User methods before UserData has been created
    static func getUserOnAppInit() async throws -> PeaUser {
        var session = try await Supabase.shared.client.auth.session
        
        if session.expiresIn < 86400 {
            session = try await Supabase.shared.client.auth.refreshSession()
            KeychainManager.shared.saveSession(session: session)
        }
        
        let retrievedUser: PeaUser = try await Supabase.shared.client
            .from("users")
            .select()
            .eq("user_id", value: session.user.id)
            .single()
            .execute()
            .value
        
        print(retrievedUser)
        
        return retrievedUser
    }
    
    static func saveUser(_ initialUser: InitialUser) async throws -> PeaUser {
        let supabase = Supabase.shared
        let user: PeaUser = try await supabase.client
          .from("users")
          .insert(initialUser, returning: .representation)
          .single()
          .execute()
          .value
        return user
    }
    
    static func getUser(with id: String) async -> PeaUser? {
        let supabase = Supabase.shared
        do {
            let retrievedUser: PeaUser = try await supabase.client
                .from("users")
                .select()
                .eq("apple_id", value: id)
                .single()
                .execute()
                .value
            print("User found:", retrievedUser)
            return retrievedUser
        } catch {
            // No user found - this is an expected condition for new users
            print("No user found with apple_id: \(id)")
            return nil
        }
    }
}
