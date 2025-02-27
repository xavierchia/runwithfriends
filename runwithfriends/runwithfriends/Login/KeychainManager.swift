



import Foundation
import Security

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
    private let appGroupIdentifier = AppDelegate.appGroupIdentifier
    
    private let userIdKey = "supabase_user_id"
    
    private init() {}
    
    // MARK: - Save Tokens
    
    func saveTokens(userId: UUID) throws {
        print("saved tokens")
        try saveToKeychain(userId.uuidString, forKey: userIdKey)
    }
    
    // MARK: - Retrieve Tokens
    
    func getUserIdToken() throws -> UUID {
        let userId = try retrieveFromKeychain(forKey: userIdKey)
        guard let userIdUUID = UUID(uuidString: userId) else {
            throw KeychainError.invalidUserIdFormat
        }
        
        return userIdUUID
    }
    
    // MARK: - Delete Tokens
    
    func deleteTokens() throws {
        print("deleting tokens")
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
