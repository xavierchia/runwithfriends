//
//  ResultsTableViewCell.swift
//  runwithfriends
//
//  Created by xavier chia on 27/11/23.
//

import UIKit

protocol ResultsTableViewCellProtocol {
    func clapPressed(with indexPath: IndexPath?)
}

class ResultsTableViewCell: UITableViewCell {
    let nameLabel = UILabel()
    let distanceLabel = UILabel()
    let clap = UIButton()
    var delegate: ResultsTableViewCellProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .cream
        self.selectionStyle = .none
        
        setupName()
        setupDistance()
        setupClap()
        setupSeparator()
    }
    
    func configure(with result: Result) {
        nameLabel.text = result.name
        nameLabel.textColor = .moss
        nameLabel.font = UIFont.chalkboardLight(size: 17)
        distanceLabel.text = result.distance
        distanceLabel.textColor = .moss
        distanceLabel.font = UIFont.chalkboardLight(size: 17)
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.accent, .pumpkin])
        let handsFilled = UIImage(systemName: "hands.clap.fill", withConfiguration: config)
        let clapImage = result.clapped ? handsFilled : UIImage(systemName: "hands.clap")
        clap.tintColor = .accent
        clap.setImage(clapImage, for: .normal)
    }
    
    private func setupName() {
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16)
        ])
    }
    
    private func setupDistance() {
        contentView.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let screenCenter = UIScreen.main.bounds.width / 2
        let middleOffset = screenCenter - 15
            
        NSLayoutConstraint.activate([
            distanceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            distanceLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: middleOffset)
        ])
    }
    
    private func setupClap() {
        clap.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clap)
        NSLayoutConstraint.activate([
            clap.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            clap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])
        clap.addTarget(self, action: #selector(clapPressed), for: .touchUpInside)
    }
    
    private func setupSeparator() {
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
    
    @objc func clapPressed() {
        print("clap pressed")
        delegate?.clapPressed(with: indexPath)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
