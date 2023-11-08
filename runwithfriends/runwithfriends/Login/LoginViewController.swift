//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import AuthenticationServices
import UIKit

class LoginViewController: UIViewController {
    let textStackView = UIStackView()
    let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    var topConstraint: NSLayoutConstraint?

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
            if credentials.fullName == nil {
                print("User fullName is not provided at login, we will use the defaultUsername")
            }
            
            let userId = credentials.user
            let username = credentials.fullName?.givenName ?? UserData.defaultUsername

            do {
                UserData.shared.setUsername(username)
                try AppKeychain.set(userId, key: AppKeys.userId)
            } catch {
                print("user credentials could not be saved to keychain")
            }
            self.view.window?.rootViewController = TabViewController()
            break
        default:
            break
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
