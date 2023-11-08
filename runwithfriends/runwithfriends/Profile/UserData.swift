//
//  UserData.swift
//  runwithfriends
//
//  Created by xavier chia on 7/11/23.
//

import Foundation

let Prefixes: [Character: [String]] = [
    "A": ["Amazing", "Active", "Adventure", "Awesome", "Affable", "Absolute", "Accomplished", "Athlete", "Adaptable", "Agile"],
    "B": ["Balanced", "Benevolent", "Blazing", "Bold", "Boss", "Brave", "Brilliant", "Bubbly", "Brisk", "Bright"],
    "C": ["Classic", "Calm", "Can-do", "Caring", "Celestial", "Centered", "Champion", "Charming", "Cheerful", "Chirpy", "Classy", "Clever", "Collected", "Committed", "Complete", "Composed", "Confident", "Consistent", "Cosmic", "Cozy", "Courageous", "Curious", "Cute", "Cuddly"],
    "D": ["Dreamy", "Dear", "Dauntless", "Decisive", "Dedicated", "Deep", "Definite", "Deliberate", "Determined", "Delightful", "Didactic", "Different", "Disarming", "Divine", "Driven", "Dynamic"],
    "E": ["Enchanting", "Easygoing", "Ebullient", "Eclectic", "Effective", "Effortless", "Elemental", "Eminent", "Endearing", "Enduring", "Enlightening", "Enriching", "Epicurean", "Essential", "Excellent", "Explorative"],
    "F": ["Friendly", "Fab", "Fantastic", "Fascinating", "Fast", "Fearless", "Fetching", "Fine", "First", "Fit", "Flash", "Flexible", "Focused", "Formidable", "Foxy", "Fresh", "Fulfilled", "Fun", "Funny"],
    "G": ["Grounded", "Generous", "Gentle", "Genuine", "Gifted", "Giddy", "Giving", "Glorious", "Glowing", "Good-looking", "Graceful", "Gracious", "Grand", "Great"],
    "H": ["Huggy", "Happy", "Harmonious", "Hard-working", "Healthy", "Heavenly", "Hilarious", "Hip", "Honest", "Humble", "Hypersonic"],
    "I": ["Idealistic", "Ideal", "Illuminating", "Imaginative", "Impassioned", "Impressive", "Inclusive", "Indomitable", "Inexhaustible", "Innovative", "Insightful", "Inquisitive", "Inspiring", "Interesting", "Intelligent", "Intense", "Intriguing"],
    "J": ["Jazzy", "Joyful", "JigJog", "Judicious", "Jade", "Jelly", "Jungle", "Jaunty", "Jiffy", "Jiggy"],
    "K": ["Kinetic", "Kind", "Key", "Knightly", "Knowing", "Kahuna", "Kickstarter", "Kumbaya", "Kiwi", "Keeper"],
    "L": ["Legit", "Laid-back", "Leading", "Learned", "Legendary", "Leisurely", "Likable", "Lively", "Lovable", "Lucky", "Lucid"],
    "M": ["Main", "Made", "Magical", "Magnetic", "Magnificent", "Major", "Manifest", "Marvelous", "Meaningful", "Mellow", "Merry", "Meteoric", "Methodical", "Momentous", "Motivated"],
    "N": ["Nimble", "Natural", "Notable", "Nice", "Ninja", "Natty", "Nomad", "Neighborly"],
    "O": ["Original", "Optimal", "Optimistic", "Organized", "Outstanding", "Overjoyed", "Oatmeal", "Owl", "Ocean", ],
    "P": ["Present", "Peaceful", "Peachy", "Persistent", "Patient", "Passionate", "Phenomenal", "Playful", "Precise", "Progressive", "Purposeful"],
    "Q": ["Quirky", "Quick", "Quaint", "Quality", "Quotable", "Quizzical", "Quick-witted"],
    "R": ["Rugged", "Rad", "Radiant", "Razor-sharp", "Real", "Ready", "Receptive", "Refined", "Reflective", "Refreshing", "Relaxed", "Reliable", "Remarkable", "Resilient", "Resolute", "Resolved", "Rooted"],
    "S": ["Smooth", "Sage", "Sanguine", "Sassy", "Sentimental", "Serene", "Settled", "Sharp", "Smashing", "Smart", "Solid", "Sparkling", "Speedy", "Sporting", "Steadfast", "Striking", "Sublime", "Super", "Stylish"],
    "T": ["Traveled", "Talented", "Tasteful", "Tenacious", "Terrific", "Thoughtful", "Timeless", "Top", "Tough", "Trim", "Trusty", "True"],
    "U": ["Ultra", "Ultimate", "Unbeaten", "Uncommon", "Unique", "Unshaken", "Uplifting", "Upstanding", "Upbeat", "Upcoming"],
    "V": ["Victorious", "Versatile", "Visionary", "Velvet", "Very", "Valued", "Vital", "Valorous"],
    "W": ["Wholesome", "Warm", "Well-liked", "Wonderful", "Worthy", "Witty", "Wise", "Worldly", "Whimsical", "Whiz-kid"],
    "X": ["Exceptional", "Extreme", "Foxy", "Maximum", "Excited", "Flexible", "Excellent", "Dexterous", "Exquisite", "Exuberant", "Expressive"],
    "Y": ["Yummy", "Youthful", "Yakitori", "Yak", "Yoghurt", "Yoga"],
    "Z": ["Zippy", "Zealous", "Zesty", "Zazzy", "Zebra", "Zenith", "Zephyr", "ZigZag", "Zucchini"]
]

struct UserData {
    static let shared = UserData()
    static let defaultUsername = "Pea"
    
    public func setUsername(_ username: String) {
        UserDefaults.standard.setValue(username, forKey: AppKeys.username)
        // set on firebase as well
        return
    }
    
    public func getUsername(withPrefix: Bool) -> String {
        var username = UserDefaults.standard.string(forKey: AppKeys.username) ?? UserData.defaultUsername
        // add prefix
        if withPrefix,
        let usernameFirstChar = username.first {
            let prefix = getPrefix(for: usernameFirstChar)
            username = "\(prefix) \(username)"
        }
        return username
    }
    
    // create prefix logic
    private func getPrefix(for character: Character) -> String {
        let resultPrefix = Prefixes[character]?.shuffled().first
        return resultPrefix ?? ""
    }
}
