//
//  ResultsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 22/11/23.
//

import UIKit
import AVFoundation

enum Relationship {
    case you, friends, everyone
}

struct Result {
    let relationship: Relationship
    let name: String
    let distance: String
    var clapped: Bool
}

class ResultsViewController: UIViewController {
    private let runManager: RunManager
    private var results = [Runner]()
    
    private var indicator = UIActivityIndicatorView()
    private let resultsTableView = UITableView(frame: .zero, style: .grouped)
    
    init(with runManager: RunManager) {
        self.runManager = runManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cream
                
        setupNavigationController()
        setupTableView()
        
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = .large
        indicator.hidesWhenStopped = true
        indicator.center = CGPoint(x: view.center.x, y: view.center.y + 80)
        indicator.color = .pumpkin
        self.view.addSubview(indicator)
        indicator.startAnimating()
        
        Task {
            // Upsert when run is complete
            let totalDistance = self.runManager.totalDistance
            await runManager.upsertRunSession(with: Int(totalDistance))
            await runManager.userData.syncUserSessions()
            await runManager.userData.syncUser()
            
            if runManager.run.type != .solo {
                // Wait 5 seconds for everyone to post their runs
                let seconds = 5
                let duration = UInt64(seconds * 1_000_000_000)
                try await Task.sleep(nanoseconds: duration)
                
                // Get all the runs and update table
                await runManager.syncRun()
            }

            let user = runManager.userData.user
            let ownRun = Runner(user_id: user.user_id, username: user.username, emoji: user.emoji, longitude: 0, latitude: 0, distance: runManager.userData.getTotalDistance())
            results = [ownRun]
            indicator.stopAnimating()
            resultsTableView.reloadData()
        }
    }
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Run complete"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        var config = UIImage.SymbolConfiguration(weight: .bold)
        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
        let pointConfig = UIImage.SymbolConfiguration(pointSize: 20)
        config = config.applying(largeConfig).applying(pointConfig)
        let closeButtonImage = UIImage(systemName: "xmark", withConfiguration: config)
        
        let closeBarButtonItem = UIBarButtonItem(image: closeButtonImage,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(popToRoot))

        self.navigationItem.rightBarButtonItem = closeBarButtonItem
    }
    
    private func setupTableView() {
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.showsVerticalScrollIndicator = false
        resultsTableView.backgroundColor = .cream
        view.addSubview(resultsTableView)
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // removes unnecessary padding between table header view and first section
        resultsTableView.sectionHeaderTopPadding = .leastNonzeroMagnitude
        
        resultsTableView.separatorStyle = .none
        NSLayoutConstraint.activate([
            resultsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            resultsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            resultsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let tableHeaderView = TableHeaderView(frame: CGRect(x: 0, y: 0, width: resultsTableView.frame.width, height: 50))
        resultsTableView.tableHeaderView = tableHeaderView
        resultsTableView.register(ResultsTableViewCell.self, forCellReuseIdentifier: "resultsCell")
    }
        
    @objc private func popToRoot() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        results[section].count
        return results.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return results.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UIPaddingLabel()
        label.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30)
        label.textColor = .almostBlack
        label.backgroundColor = .cream
        label.font = UIFont.Kefir(size: 24)
        label.textAlignment = .left
        label.edgeInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        switch section {
        case 0:
            label.text = "You"
        case 1:
            label.text = "Friends"
        case 2:
            label.text = "Everyone"
        default:
            label.text = ""
        }
        
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as? ResultsTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configure(with: results[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ResultsViewController: ResultsTableViewCellProtocol {
    func clapPressed(with indexPath: IndexPath?) {
//        guard let indexPath else { return }
//        results[indexPath.section][indexPath.row].clapped.toggle()
        resultsTableView.reloadData()
    }
}

