//
//  Runner.swift
//  runwithfriends
//
//  Created by xavier chia on 15/2/24.
//

import Foundation

struct Runner: Codable {
    let user_id: UUID
    let username: String
    let emoji: String
    let longitude: Double
    let latitude: Double
    let distance: Int
}
