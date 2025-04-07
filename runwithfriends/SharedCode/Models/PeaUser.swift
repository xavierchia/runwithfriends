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
}
