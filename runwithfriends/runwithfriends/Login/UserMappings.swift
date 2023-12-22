//
//  UserMappings.swift
//  runwithfriends
//
//  Created by xavier chia on 22/12/23.
//

import Foundation

struct UserMappings {
    static func getEmoji(from locale: String?) -> String {
        guard let locale,
              let emoji = Locales[locale] else {
            return "🏃"
        }
        return emoji
    }
}
