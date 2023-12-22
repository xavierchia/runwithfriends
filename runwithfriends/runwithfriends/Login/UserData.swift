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
    
    public func getUser(refresh: Bool = false) async -> User? {
        if refresh == false,
           let user {
            return user
        }
        
        do {
            let user = try await supabase.client.auth.session.user
            let users: [User] = try await supabase.client.database
                .from("users")
                .select()
                .eq("apple_id", value: user.id)
                .execute()
                .value
            return users.first
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
        return users.first
    }
    
    public func saveUser(_ user: User) async throws {
        self.user = user
        try await supabase.client.database
          .from("users")
          .insert(user)
          .execute()
        print("User saved to database")
    }
    
    // create prefix logic
    private func getPrefix(for character: Character) -> String {
        let resultPrefix = Prefixes[character]?.shuffled().first
        return resultPrefix ?? ""
    }
}
