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
    private var day_steps: Int?
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
    
    public var currentDaySteps: Int {
        if let dayDate,
           dayDate == Date.startOfToday() {
            return day_steps ?? 0
        } else {
            return 0
        }
    }
    
    mutating public func setDaySteps(_ steps: Int) {
        self.day_steps = steps
    }
    
    public init(user_id: UUID, apple_id: String, search_id: Int, username: String, emoji: String) {
        self.user_id = user_id
        self.apple_id = apple_id
        self.search_id = search_id
        self.username = username
        self.emoji = emoji
    }
}
