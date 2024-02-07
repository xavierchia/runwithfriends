//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit
import SkeletonView

struct Run: Codable {
    let run_id: UUID
    let start_date: Int
    let end_date: Int
    let runners: [Runner]
}

struct Runner: Codable {
    let user_id: UUID
    let username: String
    let emoji: String
    let longitude: Double?
    let latitude: Double?
    let distance: Int
}

struct FriendCellData {
    let name: String
    var runsTogether: Int? = nil
    var joinRunData: Run? = nil
}

class RunsViewController: UIViewController {
    private let runsTableView = UITableView()
    private let friendsTableView = UITableView()
    private let segmentStackView = UISegmentStackView(leftTitle: "🏃 Upcoming", rightTitle: "🕺 Friends")
    
    private let calendar = Calendar.current
    
    private var runData = [Run(run_id: UUID(), start_date: 0, end_date: 0, runners: []),
                           Run(run_id: UUID(), start_date: 0, end_date: 0, runners: []),
                           Run(run_id: UUID(), start_date: 0, end_date: 0, runners: []),
                           Run(run_id: UUID(), start_date: 0, end_date: 0, runners: []),
                           Run(run_id: UUID(), start_date: 0, end_date: 0, runners: []),
                           Run(run_id: UUID(), start_date: 0, end_date: 0, runners: []),
                           Run(run_id: UUID(), start_date: 0, end_date: 0, runners: [])]
    
    private var friendsData = [FriendCellData]()
    
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
        let supabase = Supabase.shared
        Task {
            do {
                let runs: [Run] = try await supabase.client.database
                  .rpc("get_runs_next_12_hours")
                  .select()
                  .execute()
                  .value
                runData = runs
                runsTableView.reloadData()
            } catch {
                print(error)
            }

        }
        
//        let friends = ["Timmy 🇺🇸", "Fiiv 🇹🇭", "Michelle 🇺🇸", "Matteo 🇮🇹", "Amy 🇹🇼", "Phuong 🇻🇳", "Tan 🇻🇳", "Teng Chwan 🇸🇬", "Ally 🇸🇬"]
//        var isRunningCanJoinArray = [FriendCellData]()
//        var isRunningCantJoinArray = [FriendCellData]()
//        var isNotRunningArray = [FriendCellData]()
        
//        friends.forEach { friend in
//            let isRunning = Bool.random()
//            let friendCellData: FriendCellData
//            if isRunning {
//                guard let randomRun = runData.randomElement() else { return }
//                let joinRunData = JoinRunData(date: randomRun.date, runners: "dummy", canJoin: randomRun.canJoin)
//                friendCellData = FriendCellData(name: "dummy", joinRunData: joinRunData)
//                randomRun.canJoin ? isRunningCanJoinArray.append(friendCellData) : isRunningCantJoinArray.append(friendCellData)
//            } else {
//                friendCellData = FriendCellData(name: "dummy", runsTogether: Int.random(in: 5...10))
//                isNotRunningArray.append(friendCellData)
//            }
//        }
        
//        isRunningCanJoinArray.sort { firstFriend, secondFriend in
//            guard let firstDate = firstFriend.joinRunData?.date,
//                  let secondDate = secondFriend.joinRunData?.date else { return true }
//            return firstDate < secondDate
//        }
        
//        isRunningCantJoinArray.sort { firstFriend, secondFriend in
//            guard let firstDate = firstFriend.joinRunData?.date,
//                  let secondDate = secondFriend.joinRunData?.date else { return true }
//            return firstDate < secondDate
//        }
        
//        isNotRunningArray.sort { firstFriend, secondFriend in
//            guard let firstRuns = firstFriend.runsTogether,
//                  let secondRuns = secondFriend.runsTogether else { return true }
//            return firstRuns < secondRuns
//        }
        
//        friendsData.append(contentsOf: isRunningCanJoinArray)
//        friendsData.append(contentsOf: isRunningCantJoinArray)
//        friendsData.append(contentsOf: isNotRunningArray)
    }
    
    // MARK: SetupUI
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationItem.title = "30 minute runs"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupRunsTableView() {
        runsTableView.delegate = self
        runsTableView.dataSource = self
        runsTableView.isSkeletonable = true
        runsTableView.backgroundColor = .black
        runsTableView.showsVerticalScrollIndicator = true
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
        friendsTableView.showsVerticalScrollIndicator = true
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
        
//         for testing
        segmentStackView.runsButtonPressed()
        
    }
}

extension RunsViewController: UISegmentStackViewProtocol {
    func segmentLeftButtonPressed() {
        runsTableView.isHidden = false
        friendsTableView.isHidden = true
        view.sendSubviewToBack(runsTableView)
        friendsTableView.tableHeaderView = nil
        runsTableView.tableHeaderView = segmentStackView
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
    }
    
    func segmentRightButtonPressed() {
        runsTableView.isHidden = true
        friendsTableView.isHidden = false
        view.sendSubviewToBack(friendsTableView)
        runsTableView.tableHeaderView = nil
        friendsTableView.tableHeaderView = segmentStackView
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
    }
}

extension RunsViewController: UITableViewDelegate, SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        UIRunTableViewCell.identifier
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == runsTableView {
            return runData.count
        } else {
            return friendsData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UIRunTableViewCell.identifier) as? UIRunTableViewCell else {
            return UIRunTableViewCell()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navHeight = navigationController?.navigationBar.bounds.height,
           navHeight <= 44 {
            self.navigationController?.navigationBar.layer.masksToBounds = false
            self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
            self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
            self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 20)
            self.navigationController?.navigationBar.layer.shadowRadius = 10
        } else {
            self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        }
    }
}

extension RunsViewController: UIRunTableViewCellProtocol {
    func cellButtonPressed(with indexPath: IndexPath, from tableView: UITableView) {
        if tableView == runsTableView {
            let waitingRoomVC = WaitingRoomViewController(with: runData[indexPath.row], and: userData)
            show(waitingRoomVC, sender: self)
        } else {
            let friendData = friendsData[indexPath.row]
            guard let runData = friendData.joinRunData else { return }
            let waitingRoomVC = WaitingRoomViewController(with: runData, and: userData)
            show(waitingRoomVC, sender: self)
        }
    }
}
