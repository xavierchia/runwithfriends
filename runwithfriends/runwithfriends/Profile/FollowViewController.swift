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
    
    private var trueFollowing = [PeaUser]()
    private var mainTableArray = [PeaUser(username: "Loading...")]
    private let mainTableView = {
        let mainTableView = UITableView(frame: .zero, style: .insetGrouped)
        mainTableView.register(FollowCell.self, forCellReuseIdentifier: FollowCell.identifier)
        mainTableView.rowHeight = 60
        mainTableView.separatorStyle = .singleLine
        mainTableView.backgroundColor = .baseBackground
        mainTableView.sectionHeaderTopPadding = 0
        return mainTableView
    }()
    
    private lazy var searchController = { UISearchController(searchResultsController: resultsTableVC) }()
    private var results = [PeaUser]()
    private let resultsTableVC = {
        let resultsTableVC = UITableViewController(style: .insetGrouped)
        resultsTableVC.tableView.register(FollowCell.self, forCellReuseIdentifier: FollowCell.identifier)
        resultsTableVC.tableView.rowHeight = 60
        resultsTableVC.tableView.separatorStyle = .singleLine
        resultsTableVC.tableView.backgroundColor = .baseBackground
        resultsTableVC.tableView.sectionHeaderTopPadding = 0
        return resultsTableVC
    }()
    
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .baseBackground
        
        // for testing
//        PeaDefaults.shared?.set(false, forKey: UserDefaultsKey.hasSearchedFollowing)

        setupNavAndSearch()
        setupTables()

        Task { @MainActor in
            var following = await userData.getFollowingUsers()
            following.sort { $0.search_id < $1.search_id }
            trueFollowing = following
            mainTableArray = following
            mainTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupNavAndSearch() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Following"
        navigationItem.hidesSearchBarWhenScrolling = false
    
        searchController.searchBar.placeholder = "Search by id"
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func setupTables() {
        mainTableView.dataSource = self
        mainTableView.delegate = self
        
        view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        resultsTableVC.tableView.dataSource = self
        resultsTableVC.tableView.delegate = self
    }
}

extension FollowViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        results = []
        resultsTableVC.tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchForUser), object: nil)
        self.perform(#selector(searchForUser), with: nil, afterDelay: 0.25)
    }
    
    @objc private func searchForUser() {
        guard let text = searchController.searchBar.text,
              let textInt = Int(text) else { return }
        
        let user = PeaUser(username: "Loading...")
        results = [user]
        resultsTableVC.tableView.reloadData()
        
        Task { @MainActor in
            guard let retrievedUser: PeaUser = await userData.getUser(searchId: textInt) else { return }
            results = [retrievedUser]
            resultsTableVC.tableView.reloadData()
        }
        
        PeaDefaults.shared?.set(true, forKey: UserDefaultsKey.hasSearchedFollowing)
    }
}

extension FollowViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mainTableView {
            return mainTableArray.count
        } else {
            return results.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.identifier, for: indexPath) as? FollowCell else {
            return UITableViewCell()
        }
        
        let dataSource = tableView == mainTableView ? mainTableArray : results
        
        // Configure the cell
        let item = dataSource[indexPath.row]
        let isFollowing = trueFollowing.contains { $0.user_id == item.user_id }
        
        if item.username == "Loading..." {
            cell.configure(title: "Loading...", isFollowing: true)
            return cell
        }
        
        cell.configure(title: "\(item.search_id). \(item.username)", isFollowing: isFollowing)
        
        // Set up the button action
        cell.buttonTapHandler = { [weak self] followAction in
            if followAction == .follow {
                self?.trueFollowing.append(item)
                self?.mainTableArray.prependIfNotExists(item)
                self?.mainTableView.reloadData()
            } else {
                self?.trueFollowing.removeAll(where: {$0.user_id == item.user_id})
                
                if tableView == self?.resultsTableVC.tableView,
                   let row = self?.mainTableArray.firstIndex(where: {$0.user_id == item.user_id}) {
                    let indexPath = IndexPath(row: row, section: 0)
                    self?.mainTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let defaults = PeaDefaults.shared else { return nil }
        
        if tableView == mainTableView {
            var headerHeight: CGFloat = 20
            var headerText = "Your search id is \(userData.user.search_id)"
            if !defaults.bool(forKey: UserDefaultsKey.hasSearchedFollowing) {
                headerHeight = 60
                headerText = "Hi! 👋 You start off with five friends!\nAren't you popular 🤭"
            }

            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: headerHeight))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let attributedString = NSAttributedString(
                string: headerText,
                attributes: [
                    .paragraphStyle: paragraphStyle
                ]
            )
            label.attributedText = attributedString
            
            label.numberOfLines = 0
            headerView.backgroundColor = .baseBackground
            label.lineBreakMode = .byWordWrapping
            label.font = UIFont.QuicksandMedium(size: label.font.pointSize)
            label.textColor = .gray
            
            headerView.addSubview(label)
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let defaults = PeaDefaults.shared,
              trueFollowing.count > 0 else { return 0 }
        if tableView == mainTableView {
            if defaults.bool(forKey: UserDefaultsKey.hasSearchedFollowing) {
                return 20
            } else {
                return 60
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let defaults = PeaDefaults.shared else { return nil }
        
        if tableView == mainTableView && !defaults.bool(forKey: UserDefaultsKey.hasSearchedFollowing) {
            let footerHeight: CGFloat = 60
            let footerText = "Try searching for id 28 🧐\nThat is Ally 🙆‍♀️ our community manager"
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: footerHeight))
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: footerHeight))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let attributedString = NSAttributedString(
                string: footerText,
                attributes: [
                    .paragraphStyle: paragraphStyle
                ]
            )
            label.attributedText = attributedString
            
            label.numberOfLines = 0
            headerView.backgroundColor = .baseBackground
            label.lineBreakMode = .byWordWrapping
            label.font = UIFont.QuicksandMedium(size: label.font.pointSize)
            label.textColor = .gray
            
            headerView.addSubview(label)
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let defaults = PeaDefaults.shared else { return 0 }
        
        if tableView == mainTableView && !defaults.bool(forKey: UserDefaultsKey.hasSearchedFollowing) {
            return 60
        }
        return 0
    }
}


