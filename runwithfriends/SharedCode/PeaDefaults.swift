//
//  File.swift
//  SharedCode
//
//  Created by Xavier Chia PY on 25/3/25.
//

import Foundation

public struct PeaDefaults {
    public static let shared = UserDefaults(suiteName: PeaDefaults.identifier)
    public static let identifier = "group.com.wholesomeapps.runwithfriends"
}
