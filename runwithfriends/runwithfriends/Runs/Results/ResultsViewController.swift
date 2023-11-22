//
//  ResultsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 22/11/23.
//

import UIKit

class ResultsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationController()
        
        let closeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(popToRoot))
//        let closeBarButtonItem = UIBarButtonItem(
//            title: "Close",
//            style: .done,
//            target: self,
//            action: #selector(popToRoot)
//        )

        self.navigationItem.rightBarButtonItem = closeBarButtonItem
    }
    
    @objc private func popToRoot() {
        if let waitingVC = self.presentingViewController?.presentingViewController as? TabViewController {
            print("setting tabs")
//            print(waitingVC.self)
            waitingVC.dismiss(animated: false)
//            print(waitingVC is RunsViewController)
//            print(waitingVC.navigationController?.viewControllers)
            waitingVC.setupTabs()
            
//            waitingVC.dismiss(animated: false)
//            waitingVC.navigationController?.popViewController(animated: false)
        }
    }
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "🎊 Great Job!"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}
