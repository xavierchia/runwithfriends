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
