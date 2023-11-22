//
//  ProfileViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 6/11/23.
//

import UIKit

class ProfileViewController: UIViewController {
    
    struct CellData {
        let emoji: UIImage
        let title: String
    }
    
    let settingsTableView = UITableView(frame: .zero, style: .insetGrouped)
    let tableCellTitles = [
        [
            CellData(emoji: "🥸".image(pointSize: 20), title: "Profile"),
            CellData(emoji: "🏃‍♂️".image(pointSize: 20), title: "Run settings")
        ],
        [
            CellData(emoji: "🤷‍♀️".image(pointSize: 20), title: "How it works"),
            CellData(emoji: "🕵️‍♂️".image(pointSize: 20), title: "Privacy"),
        ],
        [
            CellData(emoji: "🧐".image(pointSize: 20), title: "FAQ"),
            CellData(emoji: "⭐️".image(pointSize: 20), title: "Review"),
            CellData(emoji: "💌".image(pointSize: 20), title: "Contact"),
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupSettingsTableView()
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
            settingsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            settingsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return tableCellTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tableCellTitles[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            let data = tableCellTitles[indexPath.section][indexPath.row]
            cell.textLabel?.text = data.title
            cell.imageView?.image = data.emoji
            cell.accessoryType = .disclosureIndicator
            return cell
    }
}
