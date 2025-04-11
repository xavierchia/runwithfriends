//
//  PeaUser.swift
//  SharedCode
//
//  Created by Xavier Chia PY on 26/3/25.
//

import Foundation

public struct PeaUser: Codable, Equatable {
    public let user_id: UUID
    public let apple_id: String
    public let search_id: Int
    public let username: String
    public let emoji: String
    public var week_steps: Int?
    public var week_date: String?
    public var day_date: String?
    private let first_login: String
    private var day_steps: Int?
    
    public var weekDate: Date? {
        week_date?.getDate()
    }
    
    public var dayDate: Date? {
        day_date?.getDate()
    }
    
    public var firstLoginDate: Date {
        first_login.getDate() ?? Date.startOfToday()
    }
    
    public var currentDaySteps: Int {
        if let dayDate,
           dayDate == Date.startOfToday() {
            return day_steps ?? 0
        } else {
            return 0
        }
    }
    
    mutating public func setDayStepsAndDate(_ steps: Int) {
        self.day_steps = steps
        self.day_date = Date.startOfToday().getDateString()
    }
    
    public init(
        user_id: UUID = UUID(),
        apple_id: String = "",
        search_id: Int = 0,
        username: String,
        emoji: String = "",
        first_login: String = "",
        week_steps: Int? = nil,
        week_date: String? = nil,
        day_date: String? = nil,
        day_steps: Int? = nil
    ) {
        self.user_id = user_id
        self.apple_id = apple_id
        self.search_id = search_id
        self.username = username
        self.emoji = emoji
        self.first_login = first_login
        self.week_steps = week_steps
        self.week_date = week_date
        self.day_date = day_date
        self.day_steps = day_steps
    }
}
