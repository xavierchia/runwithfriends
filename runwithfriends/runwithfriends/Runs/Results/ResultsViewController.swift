//
//  ResultsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 22/11/23.
//

import UIKit

enum Relationship {
    case you, friends, everyone
}

struct Result {
    let relationship: Relationship
    let name: String
    let distance: String
    let clapped: Bool
}

class ResultsViewController: UIViewController {
    
    let resultsTableView = UITableView()
    
    let results = [
        [
            Result(relationship: .you, name: "XavyBoy 🇸🇬", distance: "2.23km", clapped: false)
        ],
        [
            Result(relationship: .friends, name: "Timmy 🇺🇸", distance: "3.31km 🏃", clapped: false),
            Result(relationship: .friends, name: "Fiiv 🇹🇭", distance: "4.01km 🏅", clapped: true)
        ],
        [
            Result(relationship: .everyone, name: "Michelle 🇺🇸", distance: "3.51km", clapped: true)
        ]
        
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationController()
        setupTableView()
    }
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "🎊 Great Job!"
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
        if let waitingVC = self.presentingViewController?.presentingViewController as? TabViewController {
            waitingVC.dismiss(animated: true)
            waitingVC.setupTabs()
        }
    }
}

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UIPaddingLabel()
        label.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.edgeInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        switch results[section].first?.relationship {
        case .you:
            label.text = "Your run"
        case.friends:
            label.text = "Friends"
        case.everyone:
            label.text = "Everyone"
        default:
            label.text = ""
        }
        
        let separator = UIView()
        separator.backgroundColor = .accent
        separator.translatesAutoresizingMaskIntoConstraints = false
        label.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: label.bottomAnchor),
            separator.leftAnchor.constraint(equalTo: label.leftAnchor, constant: 16),
            separator.rightAnchor.constraint(equalTo: label.rightAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as? ResultsTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: results[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
