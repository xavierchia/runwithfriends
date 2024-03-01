//
//  DistanceViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 1/3/24.
//

import UIKit

class DistanceViewController: UIViewController {
    
    private let userData: UserData
    
    private let distanceTableView = UITableView(frame: .zero, style: .insetGrouped)
    
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cream
        setupNavigationController()
        setupDistanceTableView()
    }
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.title = "Milestones"
    }
    
    private func setupDistanceTableView() {
        distanceTableView.delegate = self
        distanceTableView.dataSource = self
        distanceTableView.backgroundColor = .cream
        distanceTableView.tableHeaderView = UIView()
        view.addSubview(distanceTableView)
        distanceTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            distanceTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            distanceTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            distanceTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            distanceTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
//        header.axis = .vertical
//        header.distribution = .fillProportionally
//        header.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
//        header.isLayoutMarginsRelativeArrangement = true
//        
//        header.addArrangedSubview(firstButton)
//        header.addArrangedSubview(secondButton)
//        header.addArrangedSubview(downArrowButton)
//        
//        downArrowButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
}

extension DistanceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "heylo"
//        cell.imageView?.image = data.emoji
//        cell.accessoryType = .detailButton
//        cell.tintColor = .pumpkin
        cell.backgroundColor = .shadow
        cell.textLabel?.textColor = .moss
        cell.textLabel?.font = UIFont.Kefir(size: cell.textLabel?.font.pointSize ?? 15)
        return cell
    }
    
    
}
