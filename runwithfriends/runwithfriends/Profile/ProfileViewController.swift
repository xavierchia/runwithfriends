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
    
    enum HeaderState {
        case compact
        case expanded
    }
    
    var headerState: HeaderState = .compact
    
    private let settingsTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let tableCellTitles = [
        [
            //              CellData(emoji: "🥸".image(pointSize: 20), title: "Coming Soon!"),
            
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
    private var navImageView = UIImageView()
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
        view.backgroundColor = .cream
        setupNavigationController()
        setupSettingsTableView()
        self.navigationItem.title = "Loading..."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfile(with: userData.user)
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
        settingsTableView.backgroundColor = .cream
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
        cell.backgroundColor = .shadow
        cell.textLabel?.textColor = .moss
        cell.textLabel?.font = UIFont.Kefir(size: cell.textLabel?.font.pointSize ?? 15)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let distance = userData.getTotalDistance()
        
        let header = UIButton()
        header.setTitleColor(.moss, for: .normal)
        header.titleLabel?.font = UIFont.KefirLight(size: 20)
        header.titleLabel?.numberOfLines = 0
        header.contentHorizontalAlignment = .left
        header.contentVerticalAlignment = .top
        
        header.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        

        // for testing
        let report = DistanceReport.getReport(with: 2600)
        //        let report = DistanceReport.getReport(with: distance)

        if headerState == .compact {
            let attributedString = NSMutableAttributedString()
            let distanceString = NSAttributedString(string: report.currentStatus,
                                                attributes: [.font: UIFont.KefirLight(size: 20),
                                                             .foregroundColor: UIColor.moss])
            let ellipsesString =  NSAttributedString(string: "\n...\n",
                                                   attributes: [.font: UIFont.Kefir(size: 20),
                                                                .foregroundColor: UIColor.accent])
            attributedString.append(distanceString)
            attributedString.append(ellipsesString)
            header.setAttributedTitle(attributedString, for: .normal)
        } else {
            header.setTitle("\(report.currentStatus)\n\n\(report.nextGoal)\n\n", for: .normal)
        }
        return header
    }
    
    @objc func tapped() {
        headerState = headerState == .expanded ? .compact : .expanded
        self.settingsTableView.reloadData()
    }
}
