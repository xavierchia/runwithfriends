//
//  PodIntroViewController.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 26/2/25.
//

import UIKit

class PodIntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseBackground
        
        let waitingRoomTitle = UILabel()
        waitingRoomTitle.text = "Need Motivation?"
        waitingRoomTitle.font = UIFont.KefirBold(size: 28)
        waitingRoomTitle.numberOfLines = 0
        waitingRoomTitle.textAlignment = .center
        waitingRoomTitle.textColor = .baseText
        waitingRoomTitle.backgroundColor = .clear
        view.addSubview(waitingRoomTitle)
        waitingRoomTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waitingRoomTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waitingRoomTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
        ])
    }
}
