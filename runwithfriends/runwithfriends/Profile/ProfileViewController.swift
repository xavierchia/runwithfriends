//
//  ProfileViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 6/11/23.
//

import UIKit
import SharedCode

class ProfileViewController: UIViewController {
    
    enum Title {
        static let profile = "Your profile"
        static let following = "Who you follow"
        static let review = "Leave a review"
    }
    
    struct CellData {
        let emoji: UIImage
        let title: String
    }
    
    private var tableCellTitles = [
        [
            CellData(emoji: "".image(pointSize: 20), title: Title.profile),
            CellData(emoji: "🥸".image(pointSize: 20), title: Title.following)
        ],
        [
            CellData(emoji: "⭐️".image(pointSize: 20), title: Title.review)
        ]
    ]
    
    private let settingsTableView = UITableView(frame: .zero, style: .insetGrouped)
    
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
        settingsTableView.reloadData()
    }
    
    // MARK: SetupUI
    
    private func setupNavigationController() {
        navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
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
        tableCellTitles[0][0] = CellData(emoji: userData.user.emoji.image(pointSize: 20), title: Title.profile)
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
        cell.textLabel?.font = UIFont.QuicksandMedium(size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellData = tableCellTitles[indexPath.section][indexPath.row]
        
        switch cellData.title {
        case Title.profile:
            let userProfileVC = UserProfileViewController(with: userData)
            navigationController?.pushViewController(userProfileVC, animated: true)
        case Title.following:
            let followVC = FollowViewController(with: userData)
            navigationController?.pushViewController(followVC, animated: true)
        case Title.review:
            let appStoreString = "itms-apps://itunes.apple.com/gb/app/id6479013121?action=write-review&mt=8"
            guard let appStoreURL = URL(string: appStoreString) else { return }
            if UIApplication.shared.canOpenURL(appStoreURL) {
                UIApplication.shared.open(appStoreURL)
            } else {
                let alert = UIAlertController(title: "Oopsies...", message: "Please find WalkingPeas on the AppStore and write a review.\n\nThanks 🙇", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "🤨 weird...", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true)
            }
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch section {
            case 0:
                return "Personal"
            case 1:
                return "Support"
            default:
                return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .QuicksandMedium(size: 14)
        header.textLabel?.text =  header.textLabel?.text?.capitalized
        header.textLabel?.textColor = .secondaryText
    }
}
