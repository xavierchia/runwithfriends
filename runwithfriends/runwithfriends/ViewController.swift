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
    }
    
    // MARK: User interface
    
    private func addTextStack() {
        textStackView.axis = .vertical
        textStackView.distribution = .equalSpacing
        
        let firstText = UILabel().largeFont().white()
        firstText.text = "The"
        textStackView.addArrangedSubview(firstText)
        
        let secondText = UILabel().largeFont().orange()
        secondText.text = "Solemate"
        textStackView.addArrangedSubview(secondText)

        let thirdText = UILabel().largeFont().white()
        thirdText.text = "you have"
        textStackView.addArrangedSubview(thirdText)
        
        let fourthText = UILabel().largeFont().white()
        fourthText.text = "been"
        textStackView.addArrangedSubview(fourthText)
        
        let fifthText = UILabel().largeFont().white()
        fifthText.text = "looking"
        textStackView.addArrangedSubview(fifthText)
        
        let sixthText = UILabel().largeFont().white()
        sixthText.text = "for"
        textStackView.addArrangedSubview(sixthText)
        
        view.addSubview(textStackView)
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        topConstraint?.isActive = true
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            textStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
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

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("authorized")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
