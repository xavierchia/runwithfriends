//
//  PodIntroViewController.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 26/2/25.
//

import UIKit

protocol PodIntroDelegate {
    func joinGroupPressed()
}

class PodIntroViewController: UIViewController {
    
    var delegate: PodIntroDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .baseBackground
        addTopTitle()
    }
    
    private func addTopTitle() {
        let topTitle = UILabel()
        topTitle.text = "🌱 Need Inspiration?"
        topTitle.font = UIFont.KefirBold(size: 28)
        topTitle.numberOfLines = 1
        topTitle.textAlignment = .center
        topTitle.textColor = .moss
        topTitle.backgroundColor = .clear
        view.addSubview(topTitle)
        topTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
        ])
        
        let body = UILabel()
        body.attributedText = NSMutableAttributedString()
            .normal("Feet feeling stiff\nand ")
            .bold("tight?\n\n")
            .normal("Need something\nto make it ")
            .bold("right?\n\n")
            .normal("Friends by your side\nmake walking ")
            .bold("light...\n\n")
            .normal("Especially when you pass\nthem in ")
            .bold("delight! 🤭")
        body.numberOfLines = 0
        body.textAlignment = .left
        body.textColor = .baseText
        body.backgroundColor = .clear
        view.addSubview(body)
        body.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            body.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            body.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            body.topAnchor.constraint(equalTo: topTitle.bottomAnchor, constant: 22),
        ])
        
        let cta = UIButton()
        cta.setTitle("Join a Group", for: .normal)
        cta.titleLabel?.font = UIFont.KefirBold(size: 28)
        cta.backgroundColor = .accent
        cta.titleLabel?.textColor = .cream
        view.addSubview(cta)
        cta.layer.cornerRadius = 10
        cta.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cta.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            cta.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            cta.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 33),
            cta.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        cta.addTarget(self, action: #selector(joinGroupPressed), for: .touchUpInside)
    }
    
    @objc private func joinGroupPressed() {
        delegate?.joinGroupPressed()
    }
}

/*
 A 2017 meta-analysis published in the International Journal of Behavioral Nutrition and Physical Activity found that people participating in group walking programs increased their walking time by an average of 30% compared to those walking alone.
 
 
 
 A study from the University of Southern Denmark reported that 68% of participants in walking groups found it easier to stick to their walking routine due to accountability and social interaction.
 */
