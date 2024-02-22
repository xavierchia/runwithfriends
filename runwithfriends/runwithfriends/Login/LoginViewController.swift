//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import AuthenticationServices
import UIKit
import Supabase
import CryptoKit
import CommonCrypto

class LoginViewController: UIViewController {
    private var currentNonce: String?
    
    private let textStackView = UIStackView()
    private let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
    private var topConstraint: NSLayoutConstraint?
    private let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cream
        addTextStack()
        addSignInButton()
    }
    
    // MARK: User interface
    
    private func addTextStack() {
        textStackView.axis = .vertical
        textStackView.distribution = .equalSpacing
        textStackView.alignment = .leading
        
        let firstText = UILabel().largeLightScaled().accent()
        firstText.text = "The"
        textStackView.addArrangedSubview(firstText)
        
        let secondText = UILabel().largeLightScaled().moss()
        secondText.text = "Solemate"
        textStackView.addArrangedSubview(secondText)
        
        let thirdText = UILabel().largeLightScaled().accent()
        thirdText.text = "you have"
        textStackView.addArrangedSubview(thirdText)
        
        let fourthText = UILabel().largeLightScaled().accent()
        fourthText.text = "been"
        textStackView.addArrangedSubview(fourthText)
        
        let fifthText = UILabel().largeLightScaled().accent()
        fifthText.text = "looking"
        textStackView.addArrangedSubview(fifthText)
        
        let sixthText = UILabel().largeLightScaled().accent()
        sixthText.text = "for"
        textStackView.addArrangedSubview(sixthText)
                
        view.addSubview(textStackView)
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        topConstraint?.isActive = true
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            textStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
        textStackView.layoutIfNeeded()
        topConstraint?.constant = textStackView.frame.height / 8
    }
    
    private func addSignInButton() {
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        let constantHeight = textStackView.frame.height
        NSLayoutConstraint.activate([
            signInButton.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: textStackView.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: constantHeight/8),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -constantHeight/8)
        ])
        
        signInButton.addTarget(self, action: #selector(signInButtonPressed), for: .touchUpInside)
    }
    
    // MARK: Private methods
    
    @objc private func signInButtonPressed() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error signing into Apple")
        let alert = UIAlertController.Oops()
        present(alert, animated: true)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("authorized")
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = credentials.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to fetch identity token or serialize token string from data")
            return
        }
        
        let supabase = Supabase.shared
        Task {
            spinner.center = view.center
            self.view.addSubview(spinner)
            spinner.startAnimating()
            
            // sign into supabase
            guard (await supabase.signInWithApple(idToken: idTokenString, nonce: nonce)) != nil else {
                print("Error signing into Supabase.")
                showOops()
                return
            }
            
            do {
                guard let user = try await UserData.getUser(with: credentials.user) else {
                    print("User does not exist in the database, save to the database")
                    let initialUser = InitialUser(
                        apple_id: credentials.user,
                        username: credentials.fullName?.givenName ?? UserData.defaultUsername,
                        emoji: UserMappings.getEmoji(from: Locale.current.region?.identifier)
                    )
                    
                    let savedUser = try await UserData.saveUser(initialUser)
                    routeToTabVC(with: savedUser)
                    return
                }

                print("User exists in the database")
                routeToTabVC(with: user)
            } catch {
                print("Error getting user from database or saving user to database \(error)")
                showOops()
            }
            
            @MainActor func routeToTabVC(with user: User) {
                Task {
                    spinner.stopAnimating()
                    let userData = UserData(user: user)
                    await userData.syncUserSessions()
                    let tabVC = TabViewController(with: userData)
                    print("User signed in, routing to TabViewController")
                    self.view.window!.rootViewController = tabVC
                }
            }
            
            @MainActor func showOops() {
                spinner.stopAnimating()
                let alert = UIAlertController.Oops()
                present(alert, animated: true)
            }
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: Helper methods for security
extension LoginViewController {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}
