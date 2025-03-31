//
//  PodIntroViewController.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 26/2/25.
//

import UIKit
import SharedCode

class UserIntroViewController: UIViewController {
    
    private let weekSteps: Int
    
    init(weekSteps: Int) {
        self.weekSteps = weekSteps
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        if let sheet = self.sheetPresentationController {
            let fraction = UISheetPresentationController.Detent.custom { context in 480 }
            sheet.detents = [fraction]
            sheet.prefersGrabberVisible = true
        }
        
        view.backgroundColor = .baseBackground
        addTopTitle()
    }
    
    private func addTopTitle() {
        let topTitle = UILabel()
        topTitle.text = "🌱 Adventure awaits!"
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
            .normal("Have you ever ")
            .bold("dreamed of running a marathon ")
            .normal("but just don't have the legs for it?\n\nWith WalkingPeas, ")
            .bold("you can finish a marathon ")
            .normal("once a week! At only 8k steps a day, it is totally do-able!")
            .normal("\n\nYou have currently walked ")
            .bold("\(weekSteps.withCommas()) (\(weekSteps.valueKM)k) ")
            .normal("steps this week.")
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
        cta.setTitle("Keep going 💪", for: .normal)
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
        
        cta.addTarget(self, action: #selector(ctaPressed), for: .touchUpInside)
    }
    
    @objc private func ctaPressed() {
        self.dismiss(animated: true)
    }
}
