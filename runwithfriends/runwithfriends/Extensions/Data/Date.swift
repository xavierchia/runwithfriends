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
    
    func getCountdownTime() -> String? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: Date(), to: self)
        guard let minuteInt = components.minute,
              let secondInt = components.second else { return nil }
        let minuteString = String(format: "%02d", minuteInt)
        let secondString = String(format: "%02d", secondInt)
        return "\(minuteString):\(secondString)"
    }
}
