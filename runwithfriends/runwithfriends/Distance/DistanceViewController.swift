//
//  DistanceViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 1/3/24.
//

import UIKit

class DistanceViewController: UIViewController {
    
    private let userData: UserData
    
    // Distance report
    enum HeaderState {
        case current
        case next
    }
    private let header = UIStackView()
    private let firstButton = UIButton().setHeaderButton()
    private let secondButton = UIButton().setHeaderButton()
    private let downArrowButton = UIButton().setDownArrowButton()
    private var headerState: HeaderState = .current
    
    // Distance table
    private let distanceTableView = UITableView(frame: .zero, style: .insetGrouped)
    private var distanceTableRows: [Landmark]
    
    init(with userData: UserData) {
        self.userData = userData
        self.distanceTableRows = DistanceTable.getDistanceTableRows(for: userData.getTotalDistance())
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerState = .current
        distanceTableRows = DistanceTable.getDistanceTableRows(for: userData.getTotalDistance())
        print(distanceTableRows)
        distanceTableView.reloadData()
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
        
        header.axis = .vertical
        header.distribution = .fillProportionally
        header.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        header.isLayoutMarginsRelativeArrangement = true
        
        header.addArrangedSubview(firstButton)
        header.addArrangedSubview(secondButton)
        header.addArrangedSubview(downArrowButton)
        
        downArrowButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    @objc func tapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        headerState = headerState == .current ? .next : .current
        self.distanceTableView.reloadData()
    }
}

extension DistanceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        distanceTableRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let cellInfo = distanceTableRows[indexPath.row].info
        cell.textLabel?.text = cellInfo.name
        cell.imageView?.image = cellInfo.emoji.image(pointSize: 20)
        cell.selectionStyle = .none
        cell.backgroundColor = .shadow
        cell.textLabel?.textColor = .almostBlack
        cell.textLabel?.font = UIFont.Kefir(size: cell.textLabel?.font.pointSize ?? 15)
        cell.detailTextLabel?.text = cellInfo.distance == 0 ? "-" : "\(cellInfo.distance.valueShort)\(cellInfo.distance.metricShort)"
        cell.detailTextLabel?.textColor = indexPath.row == 1 ? .pumpkin : .almostBlack
        cell.detailTextLabel?.font = UIFont.Kefir(size: cell.textLabel?.font.pointSize ?? 15)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        
        let distance = userData.getTotalDistance()
        print("user's total distance is \(distance)")        
        let report = DistanceReport.getReport(with: distance)
        
        if headerState == .current {
            firstButton.setAttributedTitle(report.currentDistance, for: .normal)
            secondButton.setTitle(report.currentAchievement, for: .normal)
        } else {
            firstButton.setAttributedTitle(report.nextDistance, for: .normal)
            secondButton.setTitle(report.nextAchievement, for: .normal)
        }
        
        return header
    }
}

private extension UIButton {
    func setHeaderButton() -> UIButton {
        self.setTitleColor(.almostBlack, for: .normal)
        self.titleLabel?.font = UIFont.KefirLight(size: 20)
        self.titleLabel?.numberOfLines = 0
        self.contentHorizontalAlignment = .left
        self.contentVerticalAlignment = .top
        return self
    }
    
    func setDownArrowButton() -> UIButton {
        self.setTitle("...", for: .normal)
        self.setTitleColor(.accent, for: .normal)
        
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10)
        self.configuration = configuration
        self.setFont(UIFont.KefirBold(size: 20))
        self.contentHorizontalAlignment = .right
        self.tintColor = .accent
        return self
    }
}
