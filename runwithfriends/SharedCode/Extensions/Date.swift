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

extension Int {
    func getDate() -> Date {
        let timeInterval = TimeInterval(self)
        return NSDate(timeIntervalSince1970: timeInterval) as Date
    }
}

extension Date {
    public static func startOfWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: Date()).date!
    }
    
    public static func startOfToday() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }
    
    public static func currentWeek() -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        return weekOfYear
    }
    
    static func YearAndWeek() -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.yearForWeekOfYear, from: Date())
        return Int("\(year)\(weekOfYear)")!
    }
    
    func getDisplayTime(padZero: Bool = true) -> DisplayTime? {
        let dateFormatter = DateFormatter()
        if padZero {
            dateFormatter.dateFormat = "hh:mm a"
        } else {
            dateFormatter.dateFormat = "h:mm a"
        }
        let dateInString = dateFormatter.string(from: self)
        let dateArray = dateInString.split(separator: " ")
        guard let rawTimeString = dateArray.first,
              let rawAmOrPmString = dateArray.last else { return nil }
        return DisplayTime(time: String(rawTimeString), amOrPm: String(rawAmOrPmString))
    }
    
    public func getDateString() -> String {
        let currentDay = Calendar.current.startOfDay(for: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDay)
        return dateString
    }
}

extension Formatter {
    static let positional: DateComponentsFormatter = {
        let positional = DateComponentsFormatter()
        positional.unitsStyle = .positional
        positional.zeroFormattingBehavior = .pad
        return positional
    }()
}

extension TimeInterval {
    var positionalTime: String {
        Formatter.positional.allowedUnits = self >= 3600 ?
                                            [.hour, .minute, .second] :
                                            [.minute, .second]
        let string = Formatter.positional.string(from: self)!
        return string.hasPrefix("0") && string.count > 4 ?
            .init(string.dropFirst()) : string
    }
}
