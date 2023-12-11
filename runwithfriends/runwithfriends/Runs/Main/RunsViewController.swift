//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit

struct JoinRunData {
    var date: Date
    var runners: String
    var canJoin: Bool
}

struct FriendCellData {
    let name: String
    var runsTogether: Int? = nil
    var joinRunData: JoinRunData? = nil
}

class RunsViewController: UIViewController {
    private let runsTableView = UITableView()
    private let friendsTableView = UITableView()
    private let segmentStackView = UISegmentStackView(leftTitle: "🏃 Upcoming", rightTitle: "🕺 Friends")

    private let calendar = Calendar.current
    
    private var runData = [JoinRunData]()
    private var friendsData = [FriendCellData]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tempCreateRunData()
        
        setupNavigationController()
        segmentStackView.delegate = self
        setupRunsTableView()
        setupFriendsTableView()
        chooseTable()
    }
    
    private func tempCreateRunData() {
        var currentTimeToAdd = Date()
        
        // Round to the nearest half hour and add as first element
        let currentHour = calendar.component(.hour, from: currentTimeToAdd)
        let currentMinute = calendar.component(.minute, from: currentTimeToAdd)
        switch currentMinute {
        case ...30:
            currentTimeToAdd = calendar.date(bySettingHour: currentHour, minute: 30, second: 0, of: currentTimeToAdd)!
        default:
            currentTimeToAdd = calendar.date(bySettingHour: currentHour + 1, minute: 0, second: 0, of: currentTimeToAdd)!
        }
        
        // for testing add custom time
         currentTimeToAdd = Date().addingTimeInterval(10)
//        currentTimeToAdd = calendar.date(bySettingHour: currentHour, minute: 41, second: 0, of: currentTimeToAdd)!
        
        let firstRunData = JoinRunData(date: currentTimeToAdd, runners: "3 / 25 Runners", canJoin: true)
        runData.append(firstRunData)
        
        for index in 1...23 {
            
            let canJoin = Bool.random()
            let runners = canJoin ? index : 25
            
            let joinRunData = JoinRunData(
                date: calendar.date(byAdding: .minute, value: 30 * index, to: currentTimeToAdd)!,
                runners: "\(runners) / 25 Runners",
                canJoin: canJoin)
            runData.append(joinRunData)
        }
        
        let friends = ["Timmy 🇺🇸", "Fiiv 🇹🇭", "Michelle 🇺🇸", "Matteo 🇮🇹", "Amy 🇹🇼", "Phuong 🇻🇳", "Tan 🇻🇳", "Teng Chwan 🇸🇬", "Ally 🇸🇬"]
        var isRunningCanJoinArray = [FriendCellData]()
        var isRunningCantJoinArray = [FriendCellData]()
        var isNotRunningArray = [FriendCellData]()
        
        friends.forEach { friend in
            let isRunning = Bool.random()
            let friendCellData: FriendCellData
            if isRunning {
                guard let randomRun = runData.randomElement() else { return }
                let joinRunData = JoinRunData(date: randomRun.date, runners: randomRun.runners, canJoin: randomRun.canJoin)
                friendCellData = FriendCellData(name: friend, joinRunData: joinRunData)
                randomRun.canJoin ? isRunningCanJoinArray.append(friendCellData) : isRunningCantJoinArray.append(friendCellData)
            } else {
                friendCellData = FriendCellData(name: friend, runsTogether: Int.random(in: 5...10))
                isNotRunningArray.append(friendCellData)
            }
        }
        
        isRunningCanJoinArray.sort { firstFriend, secondFriend in
            guard let firstDate = firstFriend.joinRunData?.date,
                  let secondDate = secondFriend.joinRunData?.date else { return true }
            return firstDate < secondDate
        }
        
        isRunningCantJoinArray.sort { firstFriend, secondFriend in
            guard let firstDate = firstFriend.joinRunData?.date,
                  let secondDate = secondFriend.joinRunData?.date else { return true }
            return firstDate < secondDate
        }
        
        isNotRunningArray.sort { firstFriend, secondFriend in
            guard let firstRuns = firstFriend.runsTogether,
                  let secondRuns = secondFriend.runsTogether else { return true }
            return firstRuns < secondRuns
        }
        
        friendsData.append(contentsOf: isRunningCanJoinArray)
        friendsData.append(contentsOf: isRunningCantJoinArray)
        friendsData.append(contentsOf: isNotRunningArray)
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
    }
    
    private func setupFriendsTableView() {
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.backgroundColor = .black
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
    }
    
    private func chooseTable() {
        if friendsData.isEmpty {
            segmentStackView.runsButtonPressed()
        } else {
            segmentStackView.friendsButtonPressed()
        }
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
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 16)
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
