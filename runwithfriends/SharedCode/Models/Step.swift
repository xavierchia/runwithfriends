//
//  Step.swift
//  SharedCode
//
//  Created by Xavier Chia PY on 26/3/25.
//

import Foundation

public struct Step: Codable {
    let user_id: UUID
    let date: String
    let steps: Int
    
    public init(user_id: UUID, date: String, steps: Int) {
        self.user_id = user_id
        self.date = date
        self.steps = steps
    }
}
