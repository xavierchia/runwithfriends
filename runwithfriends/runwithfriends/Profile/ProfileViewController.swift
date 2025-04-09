//
//  ProfileViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 6/11/23.
//

import UIKit
import SharedCode

class ProfileViewController: UIViewController {
    
    struct CellData {
        let emoji: UIImage
        let title: String
    }
    
    private let settingsTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let tableCellTitles = [
        [
          CellData(emoji: "🥸".image(pointSize: 20), title: "Following")
        ]
    ]
    
//    private let tableCellTitles = [
//        [
//            CellData(emoji: "🥸".image(pointSize: 20), title: "Profile"),
//            CellData(emoji: "🏃‍♂️".image(pointSize: 20), title: "Run settings")
//        ],
//        [
//            CellData(emoji: "🤷‍♀️".image(pointSize: 20), title: "How it works"),
//            CellData(emoji: "🕵️‍♂️".image(pointSize: 20), title: "Privacy"),
//        ],
//        [
//            CellData(emoji: "🧐".image(pointSize: 20), title: "FAQ"),
//            CellData(emoji: "⭐️".image(pointSize: 20), title: "Review"),
//            CellData(emoji: "💌".image(pointSize: 20), title: "Contact"),
//        ]
//    ]
    private let userData: UserData
    
    private let navImageView = UIImageView()
    
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseBackground
        setupNavigationController()
        setupSettingsTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfile(with: userData.user)
        self.navigationController?.navigationBar.setImageView(navImageView)
        settingsTableView.reloadData()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navImageView.removeFromSuperview()
    }
    
    // MARK: SetupUI
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationControlle\r?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let profileImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        navImageView.isUserInteractionEnabled = true
        navImageView.addGestureRecognizer(profileImageTapGestureRecognizer)
        
        let usernameTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        let navigationBar = navigationController?.navigationBar
        navigationBar?.isUserInteractionEnabled = true
        navigationBar?.addGestureRecognizer(usernameTapGestureRecognizer)
    }
    
    private func setupSettingsTableView() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.backgroundColor = .baseBackground
        settingsTableView.tableHeaderView = UIView()
        view.addSubview(settingsTableView)
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            settingsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupProfile(with user: PeaUser) {
        self.navigationItem.title = userData.user.username
        let emoji = userData.user.emoji
        navImageView.image = emoji.image(pointSize: 20)
    }
    
    @objc func usernameTapped() {
        print("username tapped")
    }
    
    @objc func handleProfileImageTapped() {
        print("profile image tapped ")
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: "profileCell")
        let data = tableCellTitles[indexPath.section][indexPath.row]
        cell.textLabel?.text = data.title
        cell.imageView?.image = data.emoji
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .shadow
        cell.textLabel?.textColor = .baseText
        cell.textLabel?.font = UIFont.QuicksandMedium(size: cell.textLabel?.font.pointSize ?? 15)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let followVC = FollowViewController(with: userData)
        navigationController?.pushViewController(followVC, animated: true)
    }
}
