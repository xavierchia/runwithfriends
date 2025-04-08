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
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task { @MainActor in
            following = await userData.getFollowingUsers()
            tableView.reloadData()
        }
        
        
        self.view.backgroundColor = .baseBackground
        
        // Configure the search controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        // Set delegates
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = true
        
        // Critical property for proper dismissal
        definesPresentationContext = true
        
        // Setup navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "Following"
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Configure table view
        tableView.register(FollowCell.self, forCellReuseIdentifier: FollowCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .baseBackground
    }
}

extension FollowViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
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
    
    
}
