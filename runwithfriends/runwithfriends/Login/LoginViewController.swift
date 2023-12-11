//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import AuthenticationServices
import UIKit
import FirebaseFirestore
import FirebaseAuth
import CryptoKit
import CommonCrypto

class LoginViewController: UIViewController {
    private var currentNonce: String?
    
    private let textStackView = UIStackView()
    private let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    private var topConstraint: NSLayoutConstraint?
    private let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        addTextStack()
        addSignInButton()
    }
    
    // MARK: User interface
    
    private func addTextStack() {
        textStackView.axis = .vertical
        textStackView.distribution = .equalSpacing
        textStackView.alignment = .leading
        
        let firstText = UILabel().largeLightScaled().white()
        firstText.text = "The"
        textStackView.addArrangedSubview(firstText)
        
        let secondText = UILabel().largeLightScaled().accent()
        secondText.text = "Solemate"
        textStackView.addArrangedSubview(secondText)
        
        let thirdText = UILabel().largeLightScaled().white()
        thirdText.text = "you have"
        textStackView.addArrangedSubview(thirdText)
        
        let fourthText = UILabel().largeLightScaled().white()
        fourthText.text = "been"
        textStackView.addArrangedSubview(fourthText)
        
        let fifthText = UILabel().largeLightScaled().white()
        fifthText.text = "looking"
        textStackView.addArrangedSubview(fifthText)
        
        let sixthText = UILabel().largeLightScaled().white()
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
        print("error")
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
        
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                       rawNonce: nonce,
                                                       fullName: credentials.fullName)
        
        // sign in to firebase
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let self,
            let authResult else {
                print("We have an authentication error during sign in")
                return
            }
            
            print("user is signed in to firebase with apple")
            let db = Firestore.firestore()
            let username = credentials.fullName?.givenName ?? UserData.defaultUsername
            let googleUserID = authResult.user.uid
            
            spinner.center = view.center
            self.view.addSubview(spinner)
            spinner.startAnimating()
            
            // check if user is already in the database
            db.collection(CollectionKeys.users)
                .document(googleUserID)
                .getDocument { (document, error) in
                    if let document = document, document.exists {
                        print("user exists in DB")
                        route()
                    } else {
                        // save new user
                        print("User does not exist, creating new user")
                        saveUserCredentialsInDB(with: googleUserID, and: username)
                    }
                }
        }
        
        func saveUserCredentialsInDB(with googleUserID: String, and username: String) {
            let db = Firestore.firestore()
            db.collection(CollectionKeys.users).document(googleUserID).setData([
                UserKeys.username: username,
            ]) { err in
                if let err {
                    print("Error writing document: \(err)")
                } else {
                    print("We have saved a new user to the DB!")
                    route()
                }
            }
        }
        
        func route(){
            spinner.stopAnimating()
            print("Presenting TabViewController")
            let tabVC = TabViewController()
            tabVC.modalPresentationStyle = .overFullScreen
            present(tabVC, animated: true)
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
