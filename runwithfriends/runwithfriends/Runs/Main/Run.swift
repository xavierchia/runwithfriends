//
//  Run.swift
//  runwithfriends
//
//  Created by xavier chia on 15/2/24.
//

import Foundation

struct Run_Raw: Codable {
    let run_id: UUID
    let start_date: Int
    let end_date: Int
    let type: RunType
}

struct Run: Codable {
    let run_id: UUID
    let start_date: Int
    let end_date: Int
    let type: RunType
    let runners: [Runner]
    
    func toRunRaw() -> Run_Raw {
        Run_Raw(run_id: self.run_id,
                start_date: self.start_date,
                end_date: self.end_date,
                type: self.type)
    }
}

enum RunType: String, Codable {
    case `public`
    case `private`
    case solo
}
