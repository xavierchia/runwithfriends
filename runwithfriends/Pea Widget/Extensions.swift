//
//  Extensions.swift
//  Pea WidgetExtension
//
//  Created by Xavier Chia PY on 12/3/25.
//

import Foundation

extension Date {
    func getDateString() -> String {
        let currentDay = Calendar.current.startOfDay(for: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDay)
        return dateString
    }
}

extension String {
    func getDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}
