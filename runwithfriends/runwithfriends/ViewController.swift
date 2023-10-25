//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import AuthenticationServices
import UIKit

class ViewController: UIViewController {
    
    let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        let firstText = UILabel().largeFont().white()
        firstText.text = "The"
        stackView.addArrangedSubview(firstText)
        
        let secondText = UILabel().largeFont().orange()
        secondText.text = "Solemate"
        stackView.addArrangedSubview(secondText)
        
        let thirdText = UILabel().largeFont().white().multiLine()
        thirdText.text = "you have been looking\nfor"
        stackView.addArrangedSubview(thirdText)
        
        let spacing = UIView()
        stackView.addArrangedSubview(spacing)
    }
}

extension UILabel {
    func largeFont() -> UILabel {
        self.font = UIFont(name: "Helvetica Neue", size: 70)
        return self
    }
    
    func orange() -> UILabel {
        self.textColor = .systemOrange
        return self
    }
    
    func white() -> UILabel {
        self.textColor = .white
        return self
    }
    
    func multiLine() -> UILabel {
        self.numberOfLines = 0
        return self
    }
}
