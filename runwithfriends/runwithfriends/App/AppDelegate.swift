//
//  AppDelegate.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import UIKit
import CoreData
import CloudKit
import AVFoundation
import SharedCode

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let appUserDefaults = PeaDefaults.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupGlobalUI()
        
        if let shared = AppDelegate.appUserDefaults,
           shared.bool(forKey: UserDefaultsKey.appFirstInstallVersion) == false {
            shared.set(true, forKey: UserDefaultsKey.appFirstInstallVersion)
            shared.set(Date(), forKey: UserDefaultsKey.lastUpdateTime)
            shared.set(Date(), forKey: UserDefaultsKey.lastNetworkUpdate)
        }
        
        print("did finish launching")
        
        return true
    }
    
    private func setupGlobalUI() {
        // MARK: Navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .baseBackground
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.moss, .font: UIFont.KefirBold(size: 22)]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.moss, .font: UIFont.KefirBold(size: 34)]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        UINavigationBar.appearance().tintColor = .accent
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "runwithfriends")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

