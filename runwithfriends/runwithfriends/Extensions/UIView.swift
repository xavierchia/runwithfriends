//
//  UIView.swift
//  runwithfriends
//
//  Created by xavier chia on 13/11/23.
//

import Foundation
import UIKit

protocol CustomViewProtocol {
    /// The content of the UIView
    var contentView: UIView! { get }
    var identifier: String { get }

    /// Attach a custom `Nib` to the view's content
    /// - Parameter customViewName: the name of the `Nib` to attachs
    func commonInit(for customViewName: String)
}

extension CustomViewProtocol where Self: UIView {

    func commonInit(for customViewName: String) {
        Bundle.main.loadNibNamed(customViewName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
