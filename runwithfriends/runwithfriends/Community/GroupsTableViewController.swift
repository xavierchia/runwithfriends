//
//  GroupsTableViewController.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 28/2/25.
//

import UIKit

class GroupsTableViewController: UITableViewController {
    
    private var groups = [Group]()
    private var loadingTimer: Timer?
    private var loadingState = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
        refreshData()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        startLoadingAnimation()
        Task {
            do {
                self.groups = try await UserData.getGroups()
                stopLoadingAnimation()
                refreshControl?.endRefreshing()
                self.navigationItem.title = "Groups"
                self.tableView.reloadData()
            }
            catch {
                self.groups = [Group]()
                stopLoadingAnimation()
                refreshControl?.endRefreshing()
                self.navigationItem.title = "Oops! Swipe down"
            }
        }
    }

    private func startLoadingAnimation() {
        // Cancel any existing timer
        loadingTimer?.invalidate()
        
        // Create a new timer that fires every 0.5 seconds
        loadingTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updateLoadingText), userInfo: nil, repeats: true)
        
        // Set initial text
        updateLoadingText()
    }

    @objc private func updateLoadingText() {
        let loadingTexts = ["Loading", "Loading.", "Loading..", "Loading..."]
        self.navigationItem.title = loadingTexts[loadingState]
        loadingState = (loadingState + 1) % 4
    }

    // Call this method when you need to stop the animation
    func stopLoadingAnimation() {
        loadingTimer?.invalidate()
        loadingTimer = nil
        loadingState = 0
    }
    
    private func setupUI() {
        self.navigationItem.title = "Loading"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        tableView.backgroundColor = .baseBackground
        tableView.register(SubtitleTableViewCell.self,
                           forCellReuseIdentifier: SubtitleTableViewCell.reuseIdentifier)
                
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
            style: .plain,
            target: self,
            action: #selector(dismissViewController)
        )
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleTableViewCell.reuseIdentifier, for: indexPath) as? SubtitleTableViewCell else {
            return UITableViewCell()
        }

        let group = groups[indexPath.row]
        cell.configureUI(with: group)
        return cell
    }
}
