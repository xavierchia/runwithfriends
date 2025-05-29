//
//  UserProfileViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 6/11/23.
//

import UIKit
import SharedCode

class UserProfileViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var userData: UserData
    private var originalUsername: String
    private var currentUsername: String
    
    enum Title {
        static let username = "Username"
        static let emoji = "Emoji"
        static let id = "ID"
    }
    
    struct CellData {
        let title: String
        let subtitle: String
        let isEditable: Bool
    }
    
    private var tableCellTitles = [[CellData]]()
    
    init(with userData: UserData) {
        self.userData = userData
        self.originalUsername = userData.user.username
        self.currentUsername = userData.user.username
        
        tableCellTitles = [
            [
                CellData(title: Title.username, subtitle: userData.user.username, isEditable: true),
                CellData(title: Title.emoji, subtitle: userData.user.emoji, isEditable: false),
                CellData(title: Title.id, subtitle: String(userData.user.search_id), isEditable: false)
            ]
        ]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseBackground
        setupNavigationController()
        setupTableView()
    }
    
    // MARK: - Setup UI
    
    private func setupNavigationController() {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .baseBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableCellTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCellTitles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellIdentifier")
        let cellData = tableCellTitles[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellData.title
        cell.detailTextLabel?.text = cellData.subtitle
        cell.accessoryType = cellData.isEditable ? .disclosureIndicator : .none
        cell.backgroundColor = .shadow
        cell.textLabel?.textColor = .baseText
        cell.textLabel?.font = UIFont.QuicksandMedium(size: 16)
        cell.detailTextLabel?.font = UIFont.QuicksandMedium(size: 16)
        return cell
    }
}
