//
//  UserData.swift
//  runwithfriends
//
//  Created by xavier chia on 7/11/23.
//
import Foundation
import CoreLocation
import Supabase

struct Step: Codable {
    let user_id: UUID
    let date: String
    let steps: Int
}

struct Group: Codable {
    let group_id: UUID
    let created_at: Date
    let name: String
    let emoji: String
    let members_count: Int
}


class UserData {
    static let defaultUsername = "Pea"
    
    @MainActor
    var user: User
    
    private var lastServerSync: Date?
    private let minimumSyncInterval: TimeInterval = 60 * 5
    
    init(user: User) {
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
    
    func getPublicUsers() async -> [User] {
        do {
            var publicUsers: [User] = try await Supabase.shared.client.from("public_users")
                .select()
                .execute()
                .value
            
            let currentUser = await self.user
            publicUsers.removeAll { publicUser in
                publicUser.user_id == currentUser.user_id
            }
            
            publicUsers.append(currentUser)
            
            return publicUsers
        } catch {
            print("unable to get public users")
            return []
        }
    }
    
    // MARK: User methods before UserData has been created
    static func getUserOnAppInit() async throws -> User {        
        var session = try await Supabase.shared.client.auth.session
        
        if session.expiresIn < 86400 {
            session = try await Supabase.shared.client.auth.refreshSession()
            KeychainManager.shared.saveSession(session: session)
        }
        
        let retrievedUser: User = try await Supabase.shared.client
            .from("users")
            .select("""
                *,
                group_users (
                    group_id
                )
            """)
            .eq("user_id", value: session.user.id)
            .single()
            .execute()
            .value
        
        print(retrievedUser)
        
        return retrievedUser
    }
    
    static func saveUser(_ initialUser: InitialUser) async throws -> User {
        let supabase = Supabase.shared
        let user: User = try await supabase.client
          .from("users")
          .insert(initialUser, returning: .representation)
          .single()
          .execute()
          .value
        return user
    }
    
    static func getUser(with id: String) async -> User? {
        let supabase = Supabase.shared
        do {
            let retrievedUser: User = try await supabase.client
                .from("users")
                .select("""
                    *,
                    group_users(
                        group_id
                    )
                """)
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
    
    static func getGroups() async throws -> [ Group ] {
        let supabase = Supabase.shared
        let groups: [Group] = try await supabase.client
            .from("groups")
            .select()
            .execute()
            .value
        return groups
    }
}
