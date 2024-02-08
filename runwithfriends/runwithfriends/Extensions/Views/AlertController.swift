//
//  AlertController.swift
//  runwithfriends
//
//  Created by xavier chia on 22/12/23.
//

import UIKit

extension UIAlertController {
    static func Oops(title: String? = nil, subtitle: String? = nil) -> UIAlertController {
        let title = title ?? "Oops... Something went wrong, try again!"
        let subtitle = subtitle ?? ""
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
}
