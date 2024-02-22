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
    let emoji: String
}

struct User: Codable {
    let user_id: UUID
    let apple_id: String
    let username: String
    let emoji: String
    let search_id: Int
    let longitude: Double?
    let latitude: Double?
}

struct UserSession: Codable {
    let run_id: UUID
    let start_date: Int
    let end_date: Int
    let distance: Int
}
