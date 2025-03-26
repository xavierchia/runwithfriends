//
//  PeaUser.swift
//  SharedCode
//
//  Created by Xavier Chia PY on 26/3/25.
//

import Foundation

public struct PeaUser: Codable {
    public let user_id: UUID
    public let apple_id: String
    public let search_id: Int
    public let username: String
    public let emoji: String
    public var week_steps: Int?
    public var day_steps: Int?
    public var group_users: group_users?
    public var week_date: String?
    public var day_date: String?
    
    public struct group_users: Codable {
        var group_id: String?
    }
    
    public var group_id: String? {
        self.group_users?.group_id
    }
    
    public var weekDate: Date? {
        week_date?.getDate()
    }
    
    public var dayDate: Date? {
        day_date?.getDate()
    }
}
