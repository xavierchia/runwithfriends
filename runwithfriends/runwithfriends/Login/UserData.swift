//
//  UserData.swift
//  runwithfriends
//
//  Created by xavier chia on 7/11/23.
//
import Foundation
import Supabase

class UserData {
    static let shared = UserData()
    static let defaultUsername = "Pea"
    let supabase = Supabase.shared
    var user: User?
    
    private init() {}
    
    /// Get the user from memory if cached, if not retrieve again from server
    public func getUser() async -> User? {
        if let user {
            return user
        }
        
        do {
            let user = try await supabase.client.auth.session.user
            let retrievedUser: User = try await supabase.client.database
                .from("users")
                .select()
                .eq("user_id", value: user.id)
                .single()
                .execute()
                .value
            
            self.user = retrievedUser
            return retrievedUser
        } catch {
            return nil
        }
    }
    
    public func getUser(with id: String) async throws -> User? {
        let users: [User] = try await supabase.client.database
            .from("users")
            .select()
            .eq("apple_id", value: id)
            .execute()
            .value
        let retrievedUser = users.first
        self.user = retrievedUser
        return retrievedUser
    }
    
    public func saveUser(_ initialUser: InitialUser) async throws {
        let user: User = try await supabase.client.database
          .from("users")
          .insert(initialUser, returning: .representation)
          .single()
          .execute()
          .value
        print("xxavier user saved \(user)")
        self.user = user
    }
}
