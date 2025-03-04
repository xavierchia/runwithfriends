//
//  User.swift
//  runwithfriends
//
//  Created by xavier chia on 22/12/23.
//

import Foundation

struct InitialUser: Codable {
    let apple_id: String
    let username: String
}

struct User: Codable {
    let user_id: UUID
    let apple_id: String
    let username: String
    let emoji: String
    let search_id: Int
    let group_users: group_users?
    
    struct group_users: Codable {
        var group_id: String?
    }
    
    var group_id: String? {
        self.group_users?.group_id
    }
}

struct Walk: Codable {
    let user_id: UUID
    let year_week: Int
    let steps: Int
    let longitude: Double
    let latitude: Double
}
