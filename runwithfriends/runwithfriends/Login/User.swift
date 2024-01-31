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
    let apple_id: String
    let username: String
    let emoji: String
    let search_id: Int
}
