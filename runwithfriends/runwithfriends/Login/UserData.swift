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
    
    public func getUsername(withPrefix: Bool = false) -> String {
        var username = "Xavier"
        // add prefix
        if withPrefix,
        let usernameFirstChar = username.first {
            let prefix = getPrefix(for: usernameFirstChar)
            username = "\(prefix) \(username)"
        }
        return username
    }
    
    /// Get the user from memory if cached, if not retrieve again from server
    public func getUser() async -> User? {
        if let user {
            return user
        }
        
        do {
            let user = try await supabase.client.auth.session.user
            let users: [User] = try await supabase.client.database
                .from("users")
                .select()
                .eq("user_id", value: user.id)
                .execute()
                .value
            let retrievedUser = users.first
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
        try await supabase.client.database
          .from("users")
          .insert(initialUser)
          .execute()

        let user = try await supabase.client.auth.session.user
        let users: [User] = try await supabase.client.database
            .from("users")
            .select()
            .eq("user_id", value: user.id)
            .execute()
            .value
        let retrievedUser = users.first
        self.user = retrievedUser
                
        // we should now save this user to coredata?
    }
    
    // create prefix logic
    private func getPrefix(for character: Character) -> String {
        let resultPrefix = Prefixes[character]?.shuffled().first
        return resultPrefix ?? ""
    }
}
