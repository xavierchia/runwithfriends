//
//  Provider.swift
//  Pea WidgetExtension
//
//  Created by Xavier Chia PY on 11/2/25.
//

import Foundation
import WidgetKit
import CoreMotion
import HealthKit

struct Provider: AppIntentTimelineProvider {
    let sharedDefaults = UserDefaults(suiteName: "group.com.wholesomeapps.runwithfriends")
    private let pedometer = CMPedometer()
    private let healthStore = HKHealthStore()
    static var networkUpdateCount = 0
    
    private func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    private func getStepsFromAllSources() async -> (steps: Int, error: String) {
        // Get steps from both sources
        async let coreMotionResult = getStepsFromCoreMotionOnly()
        async let healthKitResult = getStepsFromHealthKit()
        
        // Wait for both results
        let ((cmSteps, cmError), (hkSteps, hkError)) = await (coreMotionResult, healthKitResult)
        
        // Return the higher step count
        if cmSteps > hkSteps {
            return (cmSteps, "CM: \(cmError)")
        } else {
            return (hkSteps, "HK: \(hkError)")
        }
    }
    
    // TODO: We can use continuation.throw to throw an error and handle it later, widget should show error if necessary
    private func getStepsFromCoreMotionOnly() async -> (steps: Int, error: String) {
        guard isStepCountingAvailable() else {
            return (0, "CM not available")
        }
        
        return await withCheckedContinuation { continuation in
            let startOfDay = Calendar.current.startOfDay(for: Date())
            
            pedometer.queryPedometerData(from: startOfDay, to: Date()) { data, error in
                if let error = error {
                    continuation.resume(returning: (0, error.localizedDescription))
                    return
                }
                
                if let steps = data?.numberOfSteps.intValue {
                    continuation.resume(returning: (steps, "CM success"))
                } else {
                    continuation.resume(returning: (0, "no CM data"))
                }
            }
        }
    }
    
    // New HealthKit function
    private func getStepsFromHealthKit() async -> (steps: Int, error: String) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              HKHealthStore.isHealthDataAvailable() else {
            return (0, "HK not available")
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(returning: (0, error.localizedDescription))
                    return
                }
                
                guard let quantity = result?.sumQuantity() else {
                    continuation.resume(returning: (0, "no HK data"))
                    return
                }
                
                let steps = Int(quantity.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: (steps, "HK success"))
            }
            
            self.healthStore.execute(query)
        }
    }
    
    private func getStepsFromKeychain() -> Int {
        do {
            let user = try KeychainManager.shared.getUser()
            return user.day_steps ?? 0
        } catch {
            print("unable to get user from keychain")
            return 0
        }
    }
    
    private func getCurrentData() async -> (steps: Int, error: String) {
        let (allSteps, allError) = await getStepsFromAllSources()
        var steps = getStepsFromKeychain()
        steps = max(allSteps, steps)
        
        if let lastUpdate = sharedDefaults?.object(forKey: "lastUpdateTime") as? Date {
            let isNewDay = !Calendar.current.isDate(lastUpdate, inSameDayAs: Date())
            if isNewDay {
                steps = 0
            }
        }

        
        return (steps, allError)
    }
    
    private func updateUserSteps(steps: Int) {
        guard let lastUpdate = sharedDefaults?.object(forKey: "lastUpdateTime") as? Date,
            lastUpdate.timeIntervalSinceNow < -20 else {
            return
        }
        
        do {
            var user = try KeychainManager.shared.getUser()
            user.day_steps = steps
            KeychainManager.shared.saveUser(user: user)
        } catch {
            print("unable to update user steps")
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let steps = getStepsFromKeychain()
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            steps: steps,
            family: context.family,
            friends: []
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        print("snapshot called")
        let data = await getCurrentData()
        updateUserSteps(steps: data.steps)
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: data.steps,
            family: context.family,
            friends: []
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let data = await getCurrentData()
        
        await doNetworking(context: context, steps: data.steps)
                
        Provider.networkUpdateCount += 1
        
        updateUserSteps(steps: data.steps)
        sharedDefaults?.set(Date(), forKey: "lastUpdateTime")
        
        let leaderboard = createSandwichLeaderboard(context: context)

        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: data.steps,
            family: context.family,
            friends: leaderboard
        )
            
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    private func doNetworking(context: Context, steps: Int) async {
        
        guard context.family == .systemSmall else {
            return
        }
                
        if let lastNetworkUpdate = sharedDefaults?.object(forKey: "lastNetworkUpdate") as? Date,
           lastNetworkUpdate.timeIntervalSinceNow < -20,
           Provider.networkUpdateCount % 2 == 0 {
            await Supabase.shared.setSessionIfNeeded()
            async let upsertResult: () = await Supabase.shared.upsert(steps: steps)
            async let publicUsersResult = await Supabase.shared.getPublicUsers()
            let (_, publicUsers) = await (upsertResult, publicUsersResult)
            
            let friendsProgress = publicUsers.map { user in
                return FriendProgress(user_id: user.user_id, username: user.username, steps: user.day_steps ?? 0)
            }
            
            FriendsManager.shared.updateFriends(friendsProgress)
            
            sharedDefaults?.set(Date(), forKey: "lastNetworkUpdate")
        }
    }
        
    private func createSandwichLeaderboard(context: Context) -> [FriendProgress] {
        guard context.family == .systemSmall else {
            return []
        }
        
        do {
            let publicUsers = FriendsManager.shared.getFriends()

            // Get the current user from keychain
            let user = try KeychainManager.shared.getUser()
            let currentUser = FriendProgress(user_id: user.user_id, username: user.username, steps: user.day_steps ?? 0)
            
            // Create a mutable copy of the public users
            var allUsers = publicUsers
            
            // Find if current user exists in the public users
            if let index = allUsers.firstIndex(where: { $0.user_id == currentUser.user_id }) {
                // Replace with local user data which is fresher
                allUsers[index] = currentUser
            } else {
                // Add current user if not found
                allUsers.append(currentUser)
            }
            
            // Sort users by step count in descending order
            allUsers.sort {
                $0.steps > $1.steps
            }
            
            // Find current user's position in the sorted list
            guard let currentUserIndex = allUsers.firstIndex(where: { $0.user_id == currentUser.user_id }) else {
                // Fallback: return current user only if we can't find them in the sorted list
                return [currentUser]
            }
            
            // Create sandwich view based on user's position
            var sandwichLeaderboard: [FriendProgress] = []
            
            if currentUserIndex == 0 {
                // User is at the top, show them and up to 2 users below
                let endIndex = min(currentUserIndex + 3, allUsers.count)
                sandwichLeaderboard = Array(allUsers[currentUserIndex..<endIndex])
            } else if currentUserIndex == allUsers.count - 1 {
                // User is at the bottom, show up to 2 users above and them
                let startIndex = max(currentUserIndex - 2, 0)
                sandwichLeaderboard = Array(allUsers[startIndex...currentUserIndex])
            } else {
                // User is in the middle, show 1 above, them, and 1 below
                let startIndex = max(currentUserIndex - 1, 0)
                let endIndex = min(currentUserIndex + 2, allUsers.count)
                sandwichLeaderboard = Array(allUsers[startIndex..<endIndex])
            }
            
            return sandwichLeaderboard
        } catch {
            print("Failed to create sandwich leaderboard: \(error)")
            return []
        }
    }
}

