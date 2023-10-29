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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        addTextStack()
        addSignInButton()
    }
    
    private func addTextStack() {
        textStackView.axis = .vertical
        textStackView.distribution = .equalSpacing
        
        let firstText = UILabel().largeFont().white()
        firstText.text = "The"
        textStackView.addArrangedSubview(firstText)
        
        let secondText = UILabel().largeFont().orange()
        secondText.text = "Solemate"
        textStackView.addArrangedSubview(secondText)
        
        let thirdText = UILabel().largeFont().white().multiLine()
        thirdText.text = "you have been looking\nfor"
        textStackView.addArrangedSubview(thirdText)
        
        view.addSubview(textStackView)
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            textStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
    
    private func addSignInButton() {
        let bottomGuide = UILayoutGuide()
        view.addLayoutGuide(bottomGuide)
        NSLayoutConstraint.activate([
            bottomGuide.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 0),
            bottomGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            bottomGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            bottomGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: bottomGuide.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: bottomGuide.centerYAnchor),
            signInButton.widthAnchor.constraint(equalTo: bottomGuide.widthAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
