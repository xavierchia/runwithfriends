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
import SharedCode

struct Provider: AppIntentTimelineProvider {
    let sharedDefaults = PeaDefaults.shared
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
            if let currentDate = user.dayDate,
            currentDate == Date.startOfToday() {
                return user.currentDaySteps
            } else {
                return 0
            }
        } catch {
            print("unable to get user from keychain")
            return 0
        }
    }
    
    private func getCurrentData() async -> (steps: Int, error: String) {
        let (allSteps, allError) = await getStepsFromAllSources()
        var steps = getStepsFromKeychain()
        steps = max(allSteps, steps)
        
        return (steps, allError)
    }
    
    private func updateUserSteps(steps: Int) {
        do {
            var user = try KeychainManager.shared.getUser()
            user.setDayStepsAndDate(steps)
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
        
        updateUserSteps(steps: data.steps)
        
        if context.family == .systemSmall {
            await doNetworking(context: context, steps: data.steps)
        }
        
        let friends = createSandwichLeaderboard(context: context)

        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            steps: data.steps,
            family: context.family,
            friends: friends
        )
            
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    private func doNetworking(context: Context, steps: Int) async {
        await Supabase.shared.setSessionIfNeeded()
        if Provider.networkUpdateCount % 2 == 0 {
            let _: () = await Supabase.shared.upsert(steps: steps)
        } else {
            let publicUsers = await Supabase.shared.getFollowingUsers()
            FriendsManager.shared.updateFriends(publicUsers)
        }
        Provider.networkUpdateCount += 1
    }
        
    private func createSandwichLeaderboard(context: Context) -> [FriendProgress] {
        guard context.family == .systemSmall else {
            return []
        }
        
        do {
            let publicUsers = FriendsManager.shared.getFriends()

            // Get the current user from keychain
            let currentUser = try KeychainManager.shared.getUser()
            
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
            allUsers.sort { (user1: PeaUser, user2: PeaUser) in
                user1.currentDaySteps > user2.currentDaySteps
            }
            
            // Create array of all users with rankings
            var rankedUsers: [(user: PeaUser, ranking: Int)] = []
            for (index, user) in allUsers.enumerated() {
                rankedUsers.append((user: user, ranking: index + 1))  // Add 1 because rankings start at 1, not 0
            }
            
            // Find current user's position in the sorted list
            guard let currentUserIndex = rankedUsers.firstIndex(where: { $0.user.user_id == currentUser.user_id }) else {
                // Fallback: return current user only if we can't find them in the sorted list
                return [FriendProgress(
                    user_id: currentUser.user_id,
                    steps: currentUser.currentDaySteps,
                    username: currentUser.username,
                    ranking: 1
                )]
            }
            
            // Create sandwich view based on user's position
            var sandwichLeaderboard: [(user: PeaUser, ranking: Int)] = []
            
            if currentUserIndex == 0 {
                // User is at the top, show them and up to 2 users below
                let endIndex = min(currentUserIndex + 3, rankedUsers.count)
                sandwichLeaderboard = Array(rankedUsers[currentUserIndex..<endIndex])
            } else if currentUserIndex == rankedUsers.count - 1 {
                // User is at the bottom, show up to 2 users above and them
                let startIndex = max(currentUserIndex - 2, 0)
                sandwichLeaderboard = Array(rankedUsers[startIndex...currentUserIndex])
            } else {
                // User is in the middle, show 1 above, them, and 1 below
                let startIndex = max(currentUserIndex - 1, 0)
                let endIndex = min(currentUserIndex + 2, rankedUsers.count)
                sandwichLeaderboard = Array(rankedUsers[startIndex..<endIndex])
            }
            
            // Convert to FriendProgress objects
            let friendsProgress = sandwichLeaderboard.map { rankedUser in
                return FriendProgress(
                    user_id: rankedUser.user.user_id,
                    steps: rankedUser.user.currentDaySteps,
                    username: rankedUser.user.username,
                    ranking: rankedUser.ranking
                )
            }
            
            return friendsProgress
        } catch {
            print("Failed to create sandwich leaderboard: \(error)")
            return []
        }
    }
}

