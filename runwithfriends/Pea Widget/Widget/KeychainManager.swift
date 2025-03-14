



import Foundation
import Security
import Supabase

enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case itemNotFound
    case invalidItemFormat
    case invalidUserIdFormat
}

class KeychainManager {
    static let shared = KeychainManager()
    
    // Replace this with your actual app group identifier
    private let appGroupIdentifier = "group.com.wholesomeapps.runwithfriends"
    
    private let userIdKey = "supabase_user_id"
    private let accessTokenKey = "supabase_access_token"
    private let refreshTokenKey = "supabase_refresh_token"
    
    private init() {}
    
    // MARK: - Retrieve Tokens
    
    func saveSession(session: Session) throws {
        print("saved tokens")
        try saveToKeychain(session.user.id.uuidString, forKey: userIdKey)
        try saveToKeychain(session.accessToken, forKey: accessTokenKey)
        try saveToKeychain(session.refreshToken, forKey: refreshTokenKey)
    }
    
    func getSession() throws -> (userId: UUID, accessToken: String, refreshToken: String) {
        let userId = try retrieveFromKeychain(forKey: userIdKey)
        guard let userIdUUID = UUID(uuidString: userId) else {
            throw KeychainError.invalidUserIdFormat
        }
        let accessToken = try retrieveFromKeychain(forKey: accessTokenKey)
        let refreshToken = try retrieveFromKeychain(forKey: refreshTokenKey)
        
        return (userIdUUID, accessToken, refreshToken)
    }
    
    // MARK: - Delete Tokens
    
    func deleteTokens() throws {
        try deleteFromKeychain(forKey: userIdKey)
    }
    
    // MARK: - Private Helper Methods
    
    private func saveToKeychain(_ value: String, forKey key: String) throws {
        let encodedValue = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: encodedValue,
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
                kSecValueData as String: encodedValue
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
        
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        return value
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
