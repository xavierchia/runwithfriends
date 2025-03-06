//
//  GroupsTableViewController.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 28/2/25.
//

import UIKit

class GroupsTableViewController: UITableViewController {
    
    var groups = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        Task {
            do {
                self.groups = try await UserData.getGroups()
                self.tableView.reloadData()
            }
            catch {
                self.groups = [Group]()
            }
        }
    }
    
    private func setupUI() {
        self.navigationItem.title = "Groups"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        tableView.backgroundColor = .baseBackground
        tableView.register(SubtitleTableViewCell.self,
                           forCellReuseIdentifier: SubtitleTableViewCell.reuseIdentifier)
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groups.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleTableViewCell.reuseIdentifier, for: indexPath) as? SubtitleTableViewCell else {
            return UITableViewCell()
        }
        
        let group = groups[indexPath.row]
        
        cell.textLabel?.text = group.name
        let memberString = group.members_count == 1 ? "member" : "members"
        cell.detailTextLabel?.text = "\(group.members_count) \(memberString)"
        
        cell.configureUI()
        return cell
    }
}
