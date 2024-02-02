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
    let searchID: Int
    let longitude: Double?
    let latitude: Double?
}
