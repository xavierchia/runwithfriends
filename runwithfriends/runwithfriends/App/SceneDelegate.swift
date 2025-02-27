//
//  SceneDelegate.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import UIKit
import AuthenticationServices
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        print("scene connecting")
        let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window.rootViewController = launchScreen
        window.makeKeyAndVisible()
        
        Task {
            _ = await Supabase.shared.client.auth.onAuthStateChange { event, session in
                print("auth state change event \(event)")
                switch event {
                case .signedOut:
                    try? KeychainManager.shared.deleteTokens()
                    print("User signed out. Session ended.")
                default:
                    guard let session else { return }
                    try? KeychainManager.shared.saveTokens(userId: session.user.id)
                }
            }
                        
            do {
                let user = try await UserData.getUserOnAppInit()
                let userData = UserData(user: user)
                print("User signed in, routing to TabViewConroller")
                DispatchQueue.main.async {
                    window.rootViewController = TabViewController(with: userData)
                    UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
                }
            } catch {
                print("User not signed in or session token not stored, routing to LoginViewController")

                try await Supabase.shared.client.auth.signOut()

                DispatchQueue.main.async {
                    window.rootViewController = LoginViewController()
                    UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
                }
            }            
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

