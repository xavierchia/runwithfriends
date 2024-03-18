//
//  RunSettings.swift
//  runwithfriends
//
//  Created by xavier chia on 16/3/24.
//

import Foundation

enum RunFrequency: String {
    case quarterDistance,
         halfDistance,
         oneDistance,
         twoDistance,
         oneMinute,
         fiveMinutes,
         tenMinutes
}

struct RunSettings {
    static func setupRunSettingsIfNeeded() {
        if isRunSettingsSetup == false {
            runAudio = true
            runStart = true
            runComplete = true
            runTime = true
            runDistance = true
            runFrequency = RunFrequency.fiveMinutes.rawValue
            
            isRunSettingsSetup = true
        }
    }
    
    static var isRunSettingsSetup: Bool {
        get { return UserDefaults.standard.bool(forKey: UserDefaults.RunSettings.isSetup.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaults.RunSettings.isSetup.rawValue) }
    }
    
    static var runAudio: Bool {
        get { return UserDefaults.standard.bool(forKey: UserDefaults.RunSettings.runAudio.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaults.RunSettings.runAudio.rawValue) }
    }
    
    static var runStart: Bool {
        get { return UserDefaults.standard.bool(forKey: UserDefaults.RunSettings.runStart.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaults.RunSettings.runStart.rawValue) }
    }
    
    static var runComplete: Bool {
        get { return UserDefaults.standard.bool(forKey: UserDefaults.RunSettings.runComplete.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaults.RunSettings.runComplete.rawValue) }
    }
    
    static var runTime: Bool {
        get { return UserDefaults.standard.bool(forKey: UserDefaults.RunSettings.runTime.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaults.RunSettings.runTime.rawValue) }
    }
    
    static var runDistance: Bool {
        get { return UserDefaults.standard.bool(forKey: UserDefaults.RunSettings.runDistance.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaults.RunSettings.runDistance.rawValue) }
    }
    
    static var runFrequency: String {
        get { return UserDefaults.standard.string(forKey: UserDefaults.RunSettings.runFrequency.rawValue) ?? RunFrequency.fiveMinutes.rawValue }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaults.RunSettings.runFrequency.rawValue) }
    }
}
