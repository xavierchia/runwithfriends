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
    
    private let settingsTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let tableCellTitles = [
        [
              CellData(emoji: "🥸".image(pointSize: 20), title: "Coming Soon!"),

//            CellData(emoji: "🥸".image(pointSize: 20), title: "Profile"),
//            CellData(emoji: "🏃‍♂️".image(pointSize: 20), title: "Run settings")
        ],
//        [
//            CellData(emoji: "🤷‍♀️".image(pointSize: 20), title: "How it works"),
//            CellData(emoji: "🕵️‍♂️".image(pointSize: 20), title: "Privacy"),
//        ],
//        [
//            CellData(emoji: "🧐".image(pointSize: 20), title: "FAQ"),
//            CellData(emoji: "⭐️".image(pointSize: 20), title: "Review"),
//            CellData(emoji: "💌".image(pointSize: 20), title: "Contact"),
//        ]
    ]
    private var navImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationController()
        setupSettingsTableView()
        self.navigationItem.title = "Loading..."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = UserData.shared.user {
            setupProfile(with: user)
        } else {
            Task {
                guard let user = await UserData.shared.getUser() else {
                    print("no user here")
                    return
                }
                setupProfile(with: user)
            }
        }
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
    
    private func setupProfile(with user: User) {
        let emoji = user.emoji
        self.navImageView = UIImageView(image: emoji.image(pointSize: 20))
        self.navigationController?.navigationBar.setImageView(self.navImageView)
        if let prefix = getPrefix(for: user.username) {
            self.navigationItem.title = "\(prefix) \(user.username)"
        } else {
            self.navigationItem.title = user.username
        }
    }
    
    // create prefix logic
    private func getPrefix(for username: String) -> String? {
        guard let character = username.first,
              let resultPrefix = Prefixes[character]?.shuffled().first else { return nil }
        return resultPrefix
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        navigationController?.navigationBar.moveAndResizeImage(for: height, and: navImageView)
    }
}
