//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit
import SkeletonView

struct FriendCellData {
    let name: String
    var runsTogether: Int? = nil
    var joinRunData: Run? = nil
}

class RunsViewController: UIViewController {
    private let runsTableView = UITableView()
    private let friendsTableView = UITableView()
    private let segmentStackView = UISegmentStackView(leftTitle: "Runs", rightTitle: "Friends")
    private let runTableRefreshControl = UIRefreshControl()
    
    private let userData: UserData
    private let mockRunData = [Run](repeating: Run(run_id: UUID(), start_date: -1, end_date: 0, type: .public, runners: []), count: 7)
    private var runData = [Run]()
    private var friendsData = [FriendCellData]()
    
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadRunsData()
        
        setupNavigationController()
        segmentStackView.delegate = self
        setupRunsTableView()
        setupFriendsTableView()
        chooseTable()
        
        runTableRefreshControl.addTarget(self, action: #selector(self.refreshRunTable(_:)), for: .valueChanged)
        runsTableView.refreshControl = runTableRefreshControl
    }
    
    @objc func refreshRunTable(_ sender: AnyObject) {
       // Code to refresh table view
        reloadRunsData()
        self.runTableRefreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        runData = runData.filter({ run in
            run.start_date.getDate() >= Date()
        })
        
        if runData.count < 10 {
            reloadRunsData()
        } else {
            runsTableView.reloadData()
        }
    }
    
    private func reloadRunsData() {
        print("reloading runs data")
        runData = mockRunData
        runsTableView.reloadData()
        
        let supabase = Supabase.shared
        Task {
            do {
                let runs: [Run] = try await supabase.client.database
                  .rpc("get_runs_next_12_hours")
                  .select()
                  .execute()
                  .value
                runData = runs
                runData.insert(Run(run_id: UUID(), start_date: Int.max, end_date: 0, type: .solo, runners: [Runner]()), at: 0)
                runsTableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    private func reloadFriendsData() {
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
        self.navigationItem.title = "15 minute runs"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupRunsTableView() {
        runsTableView.delegate = self
        runsTableView.dataSource = self
        runsTableView.isSkeletonable = true
        runsTableView.backgroundColor = .cream
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
        friendsTableView.backgroundColor = .cream
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
        cell.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 16)
        
        if tableView == runsTableView {
            if runData[indexPath.row].start_date == -1 {
                cell.configureZombie()
                return cell
            }
            
            if runData[indexPath.row].type == .solo {
                cell.configureSoloRun()
            } else {
                cell.configure(with: runData[indexPath.row])
            }
        }
        
        else if tableView == friendsTableView {
            cell.configure(with: friendsData[indexPath.row])
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navHeight = navigationController?.navigationBar.bounds.height,
           navHeight <= 44 {
            self.navigationController?.navigationBar.layer.masksToBounds = false
            self.navigationController?.navigationBar.layer.shadowColor = UIColor.cream.cgColor
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
            runsCellPressed(with: indexPath)
        } else {
            friendsCellPressed(with: indexPath)
        }
    }
    
    private func runsCellPressed(with indexPath: IndexPath) {
        var run = runData[indexPath.row]
        
        guard run.start_date > Int(Date().timeIntervalSince1970) else {
            print("Joining a run that has already started")
            reloadRunsData()
            let alert = UIAlertController.Oops(title: "Run Started >.<")
            present(alert, animated: true)
            return
        }
        
        Task {
            if run.type == .solo {
                run = Run(run_id: UUID(), start_date: Int((Date() + 6).timeIntervalSince1970), end_date: Int((Date() + 906).timeIntervalSince1970), type: .solo, runners: [])
            }
            
            let invisibleLocationVC = InvisibleLocationViewController(with: run, and: userData)
            invisibleLocationVC.modalPresentationStyle = .overFullScreen
            present(invisibleLocationVC, animated: false)
        }

    }
    
    private func friendsCellPressed(with indexPath: IndexPath) {
//        let friendData = friendsData[indexPath.row]
//        guard let runData = friendData.joinRunData else { return }
//        let waitingRoomVC = WaitingRoomViewController(with: runData, and: userData)
//        self.present(waitingRoomVC, animated: true)
    }
}
