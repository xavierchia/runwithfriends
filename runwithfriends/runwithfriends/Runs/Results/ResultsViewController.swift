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
    }
    
    @objc private func popToRoot() {
        if let waitingVC = self.presentingViewController?.presentingViewController as? TabViewController {            waitingVC.dismiss(animated: false)
            waitingVC.setupTabs()
        }
    }
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "🎊 Great Job!"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let closeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close
                                                 , target: self,
                                                 action: #selector(popToRoot))

        self.navigationItem.rightBarButtonItem = closeBarButtonItem
    }
}
