//
//  AuthManager.swift
//  runwithfriends
//
//  Created by xavier chia on 20/12/23.
//

import Foundation
import Supabase

class Supabase {
    static let shared = Supabase()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: "https://yfzsopmnnvlbezldkstu.supabase.co", supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmenNvcG1ubnZsYmV6bGRrc3R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDMwMzA0MTgsImV4cCI6MjAxODYwNjQxOH0.hlFyXx9YazvPAOqeTtRc9WSuhwntVnGPd-OUBBVRGD8")
    
    func signInWithApple(idToken: String, nonce: String) async -> Session? {
        let credentials = OpenIDConnectCredentials(provider: .apple, idToken: idToken, nonce: nonce)
        do {
            let session = try await client.auth.signInWithIdToken(credentials: credentials)
            
            // Save tokens to keychain
            try KeychainManager.shared.saveTokens(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken
            )
            
            print("xxavier sdaving session \(session)")
            return session
        } catch {
            return nil
        }
    }
}
