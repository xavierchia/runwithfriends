//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func tempCreateRunData() {
        guard let startTimeString = Date.startOfWeekUTCString(weekOffset: 0) else {
            assertionFailure("Getting start of week timestamp has failed")
            return
        }
        let db = Firestore.firestore()
        db.collection(CollectionKeys.runs)
            .document(startTimeString)
            .getDocument(completion: { [weak self] (snapshot, error) in
                guard let self,
                      let snapshot,
                      let runs = snapshot.get(CollectionKeys.runs) as? [[String: TimeInterval]] else {
                    assertionFailure("Casting runs has failed")
                    return
                }
                
                let processedRuns = runs.filter { run in
                    guard let runTime = run[FieldKeys.startTimeUnix] else {
                        assertionFailure("Filtering runs has failed")
                        return false
                    }
                    
                    let laterThanNow = Date().timeIntervalSince1970 < runTime
                    let earlierThan12Hours = runTime < Date().timeIntervalSince1970 + 60 * 60 * 12
                    return laterThanNow && earlierThan12Hours
                }.sorted { left, right in
                    guard let leftTime = left[FieldKeys.startTimeUnix],
                          let rightTime = right[FieldKeys.startTimeUnix] else {
                        assertionFailure("Sorting runs has failed")
                        return false
                    }
                    return rightTime > leftTime
                }
                
                for run in processedRuns {
                    if let startTime = run[FieldKeys.startTimeUnix] {
                        let date = NSDate(timeIntervalSince1970: startTime) as Date
                        let canJoin = Bool.random()
                        let runners = canJoin ? Int.random(in: 5...20) : 25
                        
                        let joinRunData = JoinRunData(date: date, runners: "\(runners) / 25", canJoin: canJoin)
                        runData.append(joinRunData)
                    }
                }
                
                runsTableView.reloadData()
            })
        
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
