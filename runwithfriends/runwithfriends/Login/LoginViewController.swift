//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import AuthenticationServices
import UIKit
import FirebaseFirestore

class LoginViewController: UIViewController {
    let textStackView = UIStackView()
    let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    var topConstraint: NSLayoutConstraint?
    let spinner = UIActivityIndicatorView(style: .large)
    
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
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            let db = Firestore.firestore()
            let appleID = credentials.user
            
            spinner.center = view.center
            self.view.addSubview(spinner)
            spinner.startAnimating()
            
            // check if user is already in the database
            db.collection(CollectionKeys.users)
                .document(appleID)
                .getDocument { (document, error) in
                    if let document = document, document.exists {
                        print("user exists, getting user")
                        saveKeychainAndRoute(with: appleID)
                    } else {
                        // save new user
                        print("User does not exist, creating new user")
                        saveUserCredentialsInDB(with: credentials)
                    }
                }
        default:
            break
        }
        
        func saveUserCredentialsInDB(with credentials: ASAuthorizationAppleIDCredential) {
            let db = Firestore.firestore()
            let username = credentials.fullName?.givenName ?? UserData.defaultUsername
            let appleID = credentials.user
            db.collection(CollectionKeys.users).document(appleID).setData([
                UserKeys.username: username,
            ]) { err in
                if let err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    saveKeychainAndRoute(with: appleID)
                }
            }
        }
        
        func saveKeychainAndRoute(with appleID: String){
            // saving user-bundle-specific appleID in keychain
            do {
                print("saving appleID in keychain")
                try AppKeychain.set(appleID, key: AppKeys.userId)
            } catch {
                print("user credentials could not be saved to keychain")
            }
            spinner.stopAnimating()
            print("Presenting TabViewController")
            present(TabViewController(), animated: true)
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
