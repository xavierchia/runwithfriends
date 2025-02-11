//
//  SimpleEntry.swift
//  Pea WidgetExtension
//
//  Created by Xavier Chia PY on 11/2/25.
//

import Foundation
import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let steps: Int
    let lastError: String
    let updateCount: Int
    let lastUpdateTime: Date
    let family: WidgetFamily
}
