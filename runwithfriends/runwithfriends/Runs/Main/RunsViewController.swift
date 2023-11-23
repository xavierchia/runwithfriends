//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit

struct JoinRunData {
    var time: String
    var amOrPm: String
    var runners: String
    var canJoin: Bool
}

struct FriendCellData {
    let name: String
    var runsTogether: Int? = nil
    var joinRunData: JoinRunData? = nil
}

class RunsViewController: UIViewController {
    let runsTableView = UITableView(frame: .zero, style: .grouped)
    let friendsTableView = UITableView(frame: .zero, style: .grouped)
    let segmentStackView = UISegmentStackView(leftTitle: "🏃 Runs", rightTitle: "🕺 Friends")
        
    let runData = [
        JoinRunData(time: "11:00", amOrPm: "AM", runners: "25 / 25 runners", canJoin: false),
        JoinRunData(time: "11:30", amOrPm: "AM", runners: "25 / 25 runners", canJoin: false),
        JoinRunData(time: "12:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
        JoinRunData(time: "12:30", amOrPm: "PM", runners: "20 / 25 runners", canJoin: true),
        JoinRunData(time: "1:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
        JoinRunData(time: "1:30", amOrPm: "PM", runners: "25 / 25 runners", canJoin: false),
        JoinRunData(time: "2:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
        JoinRunData(time: "2:30", amOrPm: "PM", runners: "25 / 25 runners", canJoin: false),
        JoinRunData(time: "3:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
        JoinRunData(time: "3:30", amOrPm: "PM", runners: "12 / 25 runners", canJoin: true),
        JoinRunData(time: "4:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
    ]
    
    let friendsData = [
        FriendCellData(name: "Timmy 🇺🇸", joinRunData: JoinRunData(time: "7:00", amOrPm: "PM", runners: "13 / 25 runners", canJoin: true)),
        FriendCellData(name: "Fiiv 🇹🇭", joinRunData: JoinRunData(time: "8:00", amOrPm: "PM", runners: "25 / 25 runners", canJoin: false)),
        FriendCellData(name: "Michelle 🇺🇸", runsTogether: 9),
    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        segmentStackView.delegate = self
        setupRunsTableView()
        setupFriendsTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: SetupUI
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "30 minute runs"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupRunsTableView() {
        runsTableView.delegate = self
        runsTableView.dataSource = self
        runsTableView.backgroundColor = .black
        runsTableView.separatorColor = .darkGray
        runsTableView.showsVerticalScrollIndicator = false
        runsTableView.register(UINib(nibName: UIRunTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: UIRunTableViewCell.identifier)

        view.addSubview(runsTableView)
        runsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            runsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            runsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            runsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            runsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        segmentStackView.frame = CGRect(x: 0, y: 0, width: runsTableView.frame.width, height: 50)
        runsTableView.tableHeaderView = segmentStackView
    }
    
    private func setupFriendsTableView() {
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.backgroundColor = .black
        friendsTableView.separatorColor = .darkGray
        friendsTableView.showsVerticalScrollIndicator = false
        friendsTableView.register(UINib(nibName: UIRunTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: UIRunTableViewCell.identifier)

        view.addSubview(friendsTableView)
        friendsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            friendsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            friendsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            friendsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        friendsTableView.isHidden = true
    }
}

extension RunsViewController: UISegmentStackViewProtocol {
    func segmentLeftButtonPressed() {
        runsTableView.isHidden = false
        friendsTableView.isHidden = true
        friendsTableView.tableHeaderView = nil
        runsTableView.tableHeaderView = segmentStackView
    }
    
    func segmentRightButtonPressed() {
        runsTableView.isHidden = true
        friendsTableView.isHidden = false
        runsTableView.tableHeaderView = nil
        friendsTableView.tableHeaderView = segmentStackView
    }
}

extension RunsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == runsTableView {
            return runData.count
        } else {
            return friendsData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UIRunTableViewCell.identifier) as? UIRunTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        if tableView == runsTableView {
            cell.configure(with: runData[indexPath.row])
        } else {
            cell.configure(with: friendsData[indexPath.row])
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension RunsViewController: UIRunTableViewCellProtocol {
    func cellButtonPressed(with indexPath: IndexPath, from tableView: UITableView) {
        if tableView == runsTableView {
            let waitingRoomVC = WaitingRoomViewController(with: runData[indexPath.row])
            show(waitingRoomVC, sender: self)
        } else {
            let friendData = friendsData[indexPath.row]
            guard let runData = friendData.joinRunData else { return }
            let waitingRoomVC = WaitingRoomViewController(with: runData)
            show(waitingRoomVC, sender: self)
        }
    }
}
