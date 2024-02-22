//
//  UserData.swift
//  runwithfriends
//
//  Created by xavier chia on 7/11/23.
//
import Foundation
import CoreLocation
import Supabase

class UserData {
    static let defaultUsername = "Pea"
    let supabase = Supabase.shared
    var user: User
    var userSessions = [UserSession]()
    
    init(user: User) {
        self.user = user
    }
    
    func syncUserSessions() async {
        let supabase = Supabase.shared
        do {
            let user = try await supabase.client.auth.session.user
            let userSessions: [UserSession] = try await supabase.client.database
                .rpc("get_user_sessions", params: ["p_user_id": user.id])
                .select()
                .execute()
                .value
            print(userSessions)
            self.userSessions = userSessions
        } catch {
            print("failed to sync user sessions")
        }
    }
    
    func updateUserCoordinate(obscuredCoordinate: CLLocationCoordinate2D) {
        Task {
            do {
                let supabase = Supabase.shared.client.database
                try await supabase.from("users")
                    .update(["longitude": obscuredCoordinate.longitude, "latitude": obscuredCoordinate.latitude])
                    .eq("user_id", value: user.user_id)
                    .execute()
            } catch {
                print("failed to updated user location \(error)")
            }
        }
    }
    
    // MARK: User methods before UserData has been created
    static func getUserOnAppInit() async throws -> User {
        let supabase = Supabase.shared
        let user = try await supabase.client.auth.session.user
        let retrievedUser: User = try await supabase.client.database
            .from("users")
            .select()
            .eq("user_id", value: user.id)
            .single()
            .execute()
            .value
        
        return retrievedUser
    }
    
    static func saveUser(_ initialUser: InitialUser) async throws -> User {
        let supabase = Supabase.shared
        let user: User = try await supabase.client.database
          .from("users")
          .insert(initialUser, returning: .representation)
          .single()
          .execute()
          .value
        return user
    }
    
    static func getUser(with id: String) async throws -> User? {
        let supabase = Supabase.shared
        let users: [User] = try await supabase.client.database
            .from("users")
            .select()
            .eq("apple_id", value: id)
            .execute()
            .value
        let retrievedUser = users.first
        return retrievedUser
    }
}
