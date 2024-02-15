//
//  Run.swift
//  runwithfriends
//
//  Created by xavier chia on 15/2/24.
//

import Foundation

struct Run: Codable {
    let run_id: UUID
    let start_date: Int
    let end_date: Int
    let runners: [Runner]
}
