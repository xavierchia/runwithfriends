//
//  Date.swift
//  runwithfriends
//
//  Created by xavier chia on 1/12/23.
//

import Foundation

struct DisplayTime {
    let time: String
    let amOrPm: String
}

extension Date {
    func getDisplayTime() -> DisplayTime? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let dateInString = dateFormatter.string(from: self)
        let dateArray = dateInString.split(separator: " ")
        guard let rawTimeString = dateArray.first,
              let rawAmOrPmString = dateArray.last else { return nil }
        return DisplayTime(time: String(rawTimeString), amOrPm: String(rawAmOrPmString))
    }
    
    func startOfWeekUTC(weekOffset: Int) -> TimeInterval? {
        let currentDate = Date()
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .gmt
        
        // Calculate the start of the week based on the given offset
        if let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) {
            let startOfWeekUTC = startOfWeek.addingTimeInterval(TimeInterval(weekOffset) * 7 * 24 * 60 * 60)
            return startOfWeekUTC.timeIntervalSince1970
        }
        
        return nil
    }
}

extension TimeInterval {
    func getMinuteSecondsString(withZeroPadding: Bool = false) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]

        if withZeroPadding {
            formatter.zeroFormattingBehavior = .pad
        }
        return formatter.string(from: self)!
    }
}
