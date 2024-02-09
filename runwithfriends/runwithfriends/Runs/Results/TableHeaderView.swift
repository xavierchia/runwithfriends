//
//  TableHeaderView.swift
//  runwithfriends
//
//  Created by xavier chia on 24/11/23.
//

import UIKit

extension ResultsViewController {
    class TableHeaderView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let firstLabel = UILabel()
            firstLabel.textColor = .moss
            firstLabel.font = UIFont.chalkboardLight(size: 17)
            firstLabel.text = "🏃 First Run"
            firstLabel.textAlignment = .left
            firstLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(firstLabel)
            NSLayoutConstraint.activate([
                firstLabel.topAnchor.constraint(equalTo: self.topAnchor),
                firstLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                firstLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16)
            ])
            
            let secondLabel = UILabel()
            secondLabel.textColor = .moss
            secondLabel.font = UIFont.chalkboardLight(size: 17)
            secondLabel.text = "🏅 Personal Record"
            secondLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(secondLabel)
            NSLayoutConstraint.activate([
                secondLabel.topAnchor.constraint(equalTo: self.topAnchor),
                secondLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                secondLabel.leftAnchor.constraint(equalTo: firstLabel.rightAnchor, constant: 8)
            ])
            
            self.backgroundColor = .cream
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
