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
        distanceTableRows = DistanceTable.getDistanceTableRows(for: userData.getTotalDistance())
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
        cell.detailTextLabel?.font = UIFont.Kefir(size: cell.textLabel?.font.pointSize ?? 15)
        cell.detailTextLabel?.textColor = .almostBlack

        if indexPath.row == 0 {
            cell.detailTextLabel?.text = "\(cellInfo.distance.valueShort)\(cellInfo.distance.metricShort)"
        } else {
            cell.detailTextLabel?.attributedText = cellInfo.distance == 0 
            ? NSAttributedString(string: "-")
            : "\(cellInfo.distance.valueShort)\(cellInfo.distance.metricShort)".strikeThrough()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        
        let header = UIView()
        let tableWidth = view.frame.width - 32
        
        let distanceLabel = UILabel().setHeaderButton()
        distanceLabel.frame = CGRect(x: 0, y: 0, width: tableWidth, height: 30)
        header.addSubview(distanceLabel)
        
        let distanceLeftLabel = UILabel().setHeaderButton()
        distanceLeftLabel.frame = CGRect(x: 0, y: 30, width: tableWidth, height: 30)
        distanceLeftLabel.text = "Distance Left: 500m"
        header.addSubview(distanceLeftLabel)
        
        let emojiView = UIView(frame: CGRect(x: 0, y: 70, width: tableWidth, height: 30))
        let startImage = UIImageView(image: "🌉".image(pointSize: 30))
        startImage.frame.origin = CGPoint(x: 0, y: 0)
        emojiView.addSubview(startImage)
        let endImage = UIImageView(image: "🗻".image(pointSize: 30))
        endImage.frame.origin = CGPoint(x: tableWidth - endImage.frame.width, y: 0)
        emojiView.addSubview(endImage)
        let progressImage = UIImageView(image: "🏃".image(pointSize: 20).withHorizontallyFlippedOrientation())
        let progressImageWidth = progressImage.frame.width
        progressImage.frame.origin = CGPoint(x: 0.6/1.1 * tableWidth - progressImageWidth / 2, y: 10)
        emojiView.addSubview(progressImage)
        header.addSubview(emojiView)
        
        let progress = UIProgressView(frame: CGRect(x: 0, y: 110, width: tableWidth, height: 30))
        progress.setProgress(0.6/1.1, animated: true)
        header.addSubview(progress)
        
        let distance = userData.getTotalDistance()
        let report = DistanceReport.getReport(with: distance)
        distanceLabel.attributedText = report.currentDistance
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 135
    }
}

private extension UILabel {
    func setHeaderButton() -> UILabel {
        self.textColor = .almostBlack
        self.font = UIFont.KefirLight(size: 20)
        self.textAlignment = .left
        return self
    }
}
