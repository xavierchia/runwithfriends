//
//  SimpleEntry.swift
//  Pea WidgetExtension
//
//  Created by Xavier Chia PY on 11/2/25.
//

import Foundation
import WidgetKit

struct FriendProgress {
    let user_id: UUID
    let steps: Int
    let username: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let steps: Int
    let family: WidgetFamily
    let friends: [FriendProgress]
}
