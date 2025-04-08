//
//  FollowViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 5/4/25.
//

import UIKit
import SharedCode

class FollowViewController: UIViewController {
    private let userData: UserData
    private var following = [PeaUser]()
    
    private lazy var searchController = {
        UISearchController(searchResultsController: resultsTableVC)
    }()
    
    private let mainTableView = UITableView()
    private let resultsTableVC = UITableViewController()
    
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableVC.tableView.register(FollowCell.self, forCellReuseIdentifier: FollowCell.identifier)
        resultsTableVC.tableView.dataSource = self
        resultsTableVC.tableView.delegate = self
        resultsTableVC.tableView.rowHeight = 20
        
        Task { @MainActor in
            following = await userData.getFollowingUsers()
            following.sort { $0.search_id < $1.search_id }
            mainTableView.reloadData()
        }
        
        
        self.view.backgroundColor = .baseBackground
        
        // Configure the search controller
//        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search"
        
        // Set delegates
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        // Critical property for proper dismissal
        definesPresentationContext = true
        
        // Setup navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "Following"
        
        view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Configure table view
        mainTableView.register(FollowCell.self, forCellReuseIdentifier: FollowCell.identifier)
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.rowHeight = 60
        mainTableView.separatorStyle = .singleLine
        mainTableView.backgroundColor = .baseBackground
        mainTableView.sectionHeaderTopPadding = 0
    }
}

extension FollowViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
}

extension FollowViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if following.count == 0 {
            return 1
        } else {
            return following.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.identifier, for: indexPath) as? FollowCell else {
            return UITableViewCell()
        }
        
        if following.count == 0 {
            cell.configure(title: "Loading...", buttonTitle: "")
            return cell
        }
        
        // Configure the cell
        let item = following[indexPath.row]
        cell.configure(title: "\(item.search_id). \(item.username)", buttonTitle: "Following")
        
        // Set up the button action
//        cell.buttonTapHandler = { [weak self] in
//            self?.handleButtonTap(for: item)
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        headerView.backgroundColor = .baseBackground
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: 20))
        label.text = "Your user id is \(userData.user.search_id)"
        label.font = UIFont.QuicksandMedium(size: label.font.pointSize)
        label.textColor = .gray
        
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    
}
