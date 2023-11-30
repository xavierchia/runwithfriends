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
    var clapped: Bool
}

class ResultsViewController: UIViewController {
    
    let resultsTableView = UITableView()
    
    var results = [
        [
            Result(relationship: .you, name: "XavyBoy 🇸🇬", distance: "2.23km", clapped: false)
        ],
        [
            Result(relationship: .friends, name: "Timmy 🇺🇸", distance: "3.31km 🏃", clapped: false),
            Result(relationship: .friends, name: "Fiiv 🇹🇭", distance: "4.01km 🏅", clapped: true),
            Result(relationship: .friends, name: "Ally 🇸🇬", distance: "5.02km", clapped: true),
            Result(relationship: .friends, name: "Damien 🇸🇬", distance: "5.05km", clapped: false)

        ],
        [
            Result(relationship: .everyone, name: "Michelle 🇺🇸", distance: "3.51km", clapped: true),
            Result(relationship: .everyone, name: "George 🇺🇸", distance: "3.52km", clapped: false),
            Result(relationship: .everyone, name: "Hincapie 🇺🇸", distance: "3.53km", clapped: true),
            Result(relationship: .everyone, name: "Martha 🇺🇸", distance: "3.54km", clapped: false),
            Result(relationship: .everyone, name: "Bob 🇺🇸", distance: "3.55km", clapped: true),
            Result(relationship: .everyone, name: "Harry 🇺🇸", distance: "3.56km", clapped: false),
            Result(relationship: .everyone, name: "Hermione 🇺🇸", distance: "3.57km", clapped: false),
            Result(relationship: .everyone, name: "Ron 🇺🇸", distance: "3.58km", clapped: false),
            Result(relationship: .everyone, name: "Hagrid 🇺🇸", distance: "3.59km", clapped: true),
            Result(relationship: .everyone, name: "Dumbledore 🇺🇸", distance: "3.60km", clapped: true)
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
        resultsTableView.showsVerticalScrollIndicator = false
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
        label.backgroundColor = .black
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.edgeInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        switch results[section].first?.relationship {
        case .you:
            label.text = "You"
        case.friends:
            label.text = "Friends"
        case.everyone:
            label.text = "Everyone"
        default:
            label.text = ""
        }
        
        let separator = UIView()
        separator.backgroundColor = .white
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
        cell.delegate = self
        cell.configure(with: results[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ResultsViewController: ResultsTableViewCellProtocol {
    func clapPressed(with indexPath: IndexPath?) {
        guard let indexPath else { return }
        results[indexPath.section][indexPath.row].clapped.toggle()
        resultsTableView.reloadData()
    }
}

