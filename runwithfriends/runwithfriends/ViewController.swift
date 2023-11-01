//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import AuthenticationServices
import UIKit

class ViewController: UIViewController {
    let textStackView = UIStackView()
    let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    var topConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        addTextStack()
        addSignInButton()
        print(try? AppKeychain.get("username"))
        print(try? AppKeychain.get("userId"))
    }
    
    // MARK: User interface
    
    private func addTextStack() {
        textStackView.axis = .vertical
        textStackView.distribution = .equalSpacing
        textStackView.alignment = .trailing
        
        let firstText = UILabel().largeLight().white().multiLine()
        firstText.text = "Go as far as you can see and when you get there go\n"
        textStackView.addArrangedSubview(firstText)
        
        let secondText = UILabel().largeLight().white()
        secondText.textAlignment = .left
        secondText.text = "Further"
        textStackView.addArrangedSubview(secondText)
                
        view.addSubview(textStackView)
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        topConstraint?.isActive = true
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            textStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            firstText.widthAnchor.constraint(equalTo: textStackView.widthAnchor)
        ])
        textStackView.layoutIfNeeded()
        topConstraint?.constant = textStackView.frame.height / 6
    }
    
    private func addSignInButton() {
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        let constantHeight = textStackView.frame.height
        NSLayoutConstraint.activate([
            signInButton.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: textStackView.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: constantHeight/6),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -constantHeight/6)
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

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("authorized")
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            let username = credentials.fullName?.givenName ?? "Friendly"
            let userId = credentials.user
            do {
                try AppKeychain.set(username, key: "username")
                try AppKeychain.set(userId, key: "userId")
            } catch {
                print("user credentials could not be saved to keychain")
            }
            break
        default:
            break
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
