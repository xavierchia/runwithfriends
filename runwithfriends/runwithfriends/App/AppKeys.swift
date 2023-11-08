//
//  AppKeys.swift
//  runwithfriends
//
//  Created by xavier chia on 7/11/23.
//

import Foundation
import KeychainAccess

let AppKeychain = Keychain(service: Bundle.main.bundleIdentifier!).synchronizable(true)

enum AppKeys {
        static let userId = "userId"
        static let username = "username"
}
