import Foundation
import Security
import Supabase

enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case itemNotFound
    case invalidItemFormat
    case invalidUserIdFormat
    case encodingError
    case decodingError
}

class KeychainManager {
    static let shared = KeychainManager()
    
    // Replace this with your actual app group identifier
    private let appGroupIdentifier = AppDelegate.appGroupIdentifier
    
    private let sessionKey = "supabase_session"
    private let userKey = "supabase_user"
    
    private init() {}
    
    // MARK: - Save Tokens
    
    func saveSession(session: Session) {
        print("saving session")
        do {
            try saveObject(session, forKey: sessionKey)
        } catch {
            print("error saving session to keychain: \(error)")
        }
    }
    
    func saveUser(user: User) {
        print("saving user")
        do {
            try saveObject(user, forKey: userKey)
        } catch {
            print("error saving user to keychain: \(error)")
        }
    }
    
    func getSession() throws -> Session {
        return try retrieveObject(forKey: sessionKey)
    }
    
    // MARK: - Save and Retrieve Codable Objects
    
    /// Save any Codable object to the keychain
    private func saveObject<T: Encodable>(_ object: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            try saveToKeychainData(data, forKey: key)
        } catch {
            print("Error encoding object: \(error)")
            throw KeychainError.encodingError
        }
    }
    
    /// Retrieve any Decodable object from the keychain
    private func retrieveObject<T: Decodable>(forKey key: String) throws -> T {
        let data = try retrieveDataFromKeychain(forKey: key)
        
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            print("Error decoding object: \(error)")
            throw KeychainError.decodingError
        }
    }
    
    // MARK: - Delete Items
    
    func deleteTokens() throws {
        print("deleting tokens")
        try deleteFromKeychain(forKey: userKey)
        try deleteFromKeychain(forKey: sessionKey)
    }
    
    // MARK: - Private Helper Methods
    
    private func saveToKeychain(_ value: String, forKey key: String) throws {
        guard let encodedValue = value.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try saveToKeychainData(encodedValue, forKey: key)
    }
    
    private func saveToKeychainData(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessGroup as String: appGroupIdentifier,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecAttrAccessGroup as String: appGroupIdentifier
            ]
            
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unknown(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    private func retrieveFromKeychain(forKey key: String) throws -> String {
        let data = try retrieveDataFromKeychain(forKey: key)
        
        guard let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        return value
    }
    
    private func retrieveDataFromKeychain(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecAttrAccessGroup as String: appGroupIdentifier,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.itemNotFound
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidItemFormat
        }
        
        return data
    }
    
    private func deleteFromKeychain(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: appGroupIdentifier
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}
