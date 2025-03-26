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

struct Walk: Codable {
    let user_id: UUID
    let year_week: Int
    let steps: Int
    let longitude: Double
    let latitude: Double
}
