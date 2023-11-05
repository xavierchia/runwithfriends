//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit

class RunsViewController: UIViewController {
    let runsTableView = UITableView(frame: .zero, style: .grouped)
    let segmentStackView = UISegmentStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        segmentStackView.delegate = self
    }
    
    // MARK: SetupUI
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "5K Runs"
    }
    
    private func setupRunsTableView() {
        runsTableView.delegate = self
        runsTableView.dataSource = self
        runsTableView.backgroundColor = .black
        view.addSubview(runsTableView)
        runsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            runsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            runsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            runsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            runsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension RunsViewController: UISegmentStackViewProtocol {
    func runsButtonPressed() {
        print("runs button pressed in vc")
    }
    
    func unlockedButtonPressed() {
        print("unlocked button pressed in vc")
    }
}

extension RunsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
            
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        segmentStackView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        return segmentStackView
    }
    
    
}
