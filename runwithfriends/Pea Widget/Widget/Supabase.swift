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
    
    func getAuthenticatedClient() async throws -> SupabaseClient {
        // Get tokens from keychain
        let accessToken = try KeychainManager.shared.getAccessToken()
        let refreshToken = try KeychainManager.shared.getRefreshToken()
        
        // Set the session
        try await client.auth.setSession(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        
        return client
    }
}
