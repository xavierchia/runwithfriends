//
//  ProfileViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 6/11/23.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let segmentStackView = UISegmentStackView(leftTitle: "Settings", rightTitle: "Friends")
    let settingsTableView = UITableView(frame: .zero, style: .insetGrouped)
    let friendsTableView = UITableView(frame: .zero, style: .insetGrouped)
    let tableCellTitles = [
        ["Profile", "Run settings"],
        ["How it works", "Privacy"],
        ["FAQ", "Review", "Contact"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        segmentStackView.delegate = self
        setupSettingsTableView()
        setupFriendsTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = UserData.shared.getUsername(withPrefix: true)
    }
    
    // MARK: SetupUI
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupSettingsTableView() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        view.addSubview(settingsTableView)
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            settingsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        segmentStackView.frame = CGRect(x: 0, y: 0, width: settingsTableView.frame.width, height: 50)
        settingsTableView.tableHeaderView = segmentStackView
    }
    
    private func setupFriendsTableView() {
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        view.addSubview(friendsTableView)
        friendsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            friendsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            friendsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            friendsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        friendsTableView.isHidden = true
    }
}

extension ProfileViewController: UISegmentStackViewProtocol {
    func leftButtonPressed() {
        settingsTableView.isHidden = false
        friendsTableView.isHidden = true
        friendsTableView.tableHeaderView = nil
        settingsTableView.tableHeaderView = segmentStackView
    }
    
    func rightButtonPressed() {
        settingsTableView.isHidden = true
        friendsTableView.isHidden = false
        settingsTableView.tableHeaderView = nil
        friendsTableView.tableHeaderView = segmentStackView
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == settingsTableView {
            return tableCellTitles.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == settingsTableView {
            return tableCellTitles[section].count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == settingsTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.textLabel?.text = tableCellTitles[indexPath.section][indexPath.row]
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Coming Soon!"
            return cell
        }

    }
}
