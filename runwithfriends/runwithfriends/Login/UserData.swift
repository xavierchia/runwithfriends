//
//  UserData.swift
//  runwithfriends
//
//  Created by xavier chia on 7/11/23.
//
import Foundation

struct UserData {
    static let shared = UserData()
    static let defaultUsername = "Pea"
    
    private init() {}
    
    public func setUsername(_ username: String) {
        UserDefaults.standard.setValue(username, forKey: AppKeys.username)
        // set on firebase as well
        return
    }
    
    public func getUsername(withPrefix: Bool = false) -> String {
        var username = UserDefaults.standard.string(forKey: AppKeys.username) ?? UserData.defaultUsername
        // add prefix
        if withPrefix,
        let usernameFirstChar = username.first {
            let prefix = getPrefix(for: usernameFirstChar)
            username = "\(prefix) \(username)"
        }
        return username
    }
    
    // create prefix logic
    private func getPrefix(for character: Character) -> String {
        let resultPrefix = Prefixes[character]?.shuffled().first
        return resultPrefix ?? ""
    }
}

struct User: Codable {
    let appleID: String?
    let username: String?
}
