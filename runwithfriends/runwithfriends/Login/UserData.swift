//
//  UserData.swift
//  runwithfriends
//
//  Created by xavier chia on 7/11/23.
//
import Foundation
import CoreLocation
import Supabase

struct Walker: Codable {
    let user_id: UUID
    let username: String
    let emoji: String
    var walk: Walker.Walk
    
    struct Walk: Codable {
        var steps: Int
        var latitude: Double
        var longitude: Double
        var day_steps: Int
    }
    
    private enum CodingKeys: String, CodingKey {
        case user_id
        case username
        case emoji
        case walk = "walks"
    }
}

struct Group: Codable {
    let group_id: UUID
    let created_at: Date
    let name: String
    let emoji: String
    let members_count: Int
}


class UserData {
    static let defaultUsername = "Pea"
    var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func updateWalk(with steps: Int, and coordinate: CLLocationCoordinate2D) {
        guard steps > 0 else { return }
        Task {
            do {
                let year_week = Date.YearAndWeek()
                let walk = Walk(user_id: user.user_id, year_week: year_week, steps: steps, longitude: coordinate.longitude, latitude: coordinate.latitude)
                let supabase = Supabase.shared.client
                try await supabase.from("walks")
                    .upsert(walk)
                    .eq("user_id", value: user.user_id)
                    .eq("year_week", value: year_week)
                    .execute()
                print("updated user steps")
            } catch {
                print("failed to updated user location \(error)")
            }
        }
    }
    
    func getWalkers() async -> [Walker] {
        do {
            var walkers: [Walker] = try await Supabase.shared.client
                    .from("users")
                    .select("""
                        user_id,
                        username,
                        emoji,
                        walks!inner (
                            steps,
                            latitude,
                            longitude,
                            day_steps
                        )
                    """)
                    .execute()
                    .value
            
            walkers.removeAll { walker in
                walker.user_id == user.user_id
            }
            print(walkers)
            // Side effect: Update friends data in shared defaults
            let friends = walkers.map { FriendProgress(username: $0.username, steps: $0.walk.day_steps) }
            FriendsManager.shared.updateFriends(friends)
            
            return walkers
        } catch {
            print("failed to get walkers \(error)")
            return []
        }
    }
    
    // MARK: User methods before UserData has been created
    static func getUserOnAppInit() async throws -> User {
        let _ = try KeychainManager.shared.getUserIdToken()
        let user = try await Supabase.shared.client.auth.session.user
        let retrievedUser: User = try await Supabase.shared.client
            .from("users")
            .select("""
                user_id,
                apple_id,
                username,
                emoji,
                search_id,
                group_users!inner (
                    group_id
                )
            """)
            .eq("user_id", value: user.id)
            .single()
            .execute()
            .value
        
        return retrievedUser
    }
    
    static func saveUser(_ initialUser: InitialUser) async throws -> User {
        let supabase = Supabase.shared
        let user: User = try await supabase.client
          .from("users")
          .insert(initialUser, returning: .representation)
          .single()
          .execute()
          .value
        return user
    }
    
    static func getUser(with id: String) async throws -> User? {
        let supabase = Supabase.shared
        let retrievedUser: User = try await supabase.client
            .from("users")
            .select("""
                user_id,
                apple_id,
                username,
                emoji,
                search_id,
                group_users!inner (
                    group_id
                )
            """)
            .eq("apple_id", value: id)
            .single()
            .execute()
            .value
        print(retrievedUser)
        return retrievedUser
    }
    
    static func getGroups() async throws -> [ Group ] {
        let supabase = Supabase.shared
        let groups: [Group] = try await supabase.client
            .from("groups")
            .select()
            .execute()
            .value
        return groups
    }
}
