//
//  AlertController.swift
//  runwithfriends
//
//  Created by xavier chia on 22/12/23.
//

import UIKit

extension UIAlertController {
    static func Oops() -> UIAlertController {
        let alert = UIAlertController(title: "Oops... Something went wrong, try again!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
}
