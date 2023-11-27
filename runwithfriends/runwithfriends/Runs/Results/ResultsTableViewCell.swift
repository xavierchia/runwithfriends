//
//  ResultsTableViewCell.swift
//  runwithfriends
//
//  Created by xavier chia on 27/11/23.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {
    let nameLabel = UILabel()
    let distanceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .black
        
        self.selectionStyle = .none
        
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16)
        ])
        
        contentView.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let screenCenter = UIScreen.main.bounds.width / 2
        let middleOffset = screenCenter - 15
            
        NSLayoutConstraint.activate([
            distanceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            distanceLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: middleOffset)
        ])
        
        let clap = UIImageView(image: UIImage(systemName: "figure.run.circle"))
        clap.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clap)
        NSLayoutConstraint.activate([
            clap.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            clap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])
        
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 1))
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 32),
            separator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(with result: Result) {
        nameLabel.text = result.name
        distanceLabel.text = result.distance
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
