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
    
    func updateStepsIfNeeded(dailySteps: [DateSteps]) {
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
    
    func getFollowingUsers(currentWeekOnly: Bool) async -> [PeaUser] {
        do {
            var following: [PeaUser] = try await Supabase.shared.client
                .rpc("get_following_users", params: ["follower_id": user.user_id.uuidString])
                .execute()
                .value
            
            if currentWeekOnly {
                following = following.filter { followingUser in
                    guard let weekDate = followingUser.weekDate else { return false }
                    return weekDate == Date.startOfWeek()
                }
            }

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
    
    func updateUsername(_ newUsername: String) async -> Bool {
        do {
            let updatedUser: PeaUser = try await Supabase.shared.client
                .from("users")
                .update(["username": newUsername])
                .eq("user_id", value: user.user_id.uuidString)
                .single()
                .execute()
                .value
            
            await MainActor.run {
                self.user = updatedUser
            }
            
            print("Username updated successfully on server")
            return true
        } catch {
            print("Failed to update username on server: \(error)")
            return false
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            // The Edge Function will extract user ID from the Authorization header
            // No need to pass user_id in the body - more secure approach
            try await Supabase.shared.client.functions.invoke("delete-user-complete")
            
            // If successful, sign out from Supabase (this will trigger auth state change)
            try await Supabase.shared.client.auth.signOut()
            
            // Clear local data after successful signout
            try KeychainManager.shared.deleteTokens()
            
            print("Account deleted successfully")
            return true
        } catch let error {
            print("Failed to delete account: \(error)")
            
            // If it's a network error, the tokens might still be valid
            // Only clear tokens if we're sure the backend deletion succeeded
            if let funcError = error as? FunctionsError,
               case .httpError(let statusCode, _) = funcError,
               statusCode == 200 {
                // Backend deletion succeeded but signout failed
                try? await Supabase.shared.client.auth.signOut()
                try? KeychainManager.shared.deleteTokens()
                return true
            }
            
            return false
        }
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
