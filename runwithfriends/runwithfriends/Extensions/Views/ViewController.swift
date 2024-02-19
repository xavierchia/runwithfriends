//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 15/2/24.
//

import UIKit

extension UIViewController {
    
    func showToast(message : String, heightFromBottom: Double = 265) {
        guard view.subviews.contains(where: { view in
            view.accessibilityIdentifier == "toastView"
        }) == false else { return }
        
        let width = view.frame.width - 40
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - width/2, y: self.view.frame.size.height - heightFromBottom, width: width, height: 70))
        toastLabel.accessibilityIdentifier = "toastView"
        toastLabel.backgroundColor = UIColor.cream
        toastLabel.textColor = UIColor.accent
        toastLabel.font = UIFont.Kefir(size: 24)
        toastLabel.layer.borderColor = UIColor.accent.cgColor
        toastLabel.layer.borderWidth = 5
        toastLabel.numberOfLines = 2
        toastLabel.textAlignment = .center;
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1.0
            toastLabel.frame = CGRect(x: self.view.frame.size.width/2 - width/2, y: self.view.frame.size.height - heightFromBottom - 10, width: width, height: 70)
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, delay: 1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}
