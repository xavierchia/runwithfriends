//
//  DistanceViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 1/3/24.
//

import UIKit

class DistanceViewController: UIViewController {
    
    private let userData: UserData
    private var distance: Int {
        userData.getTotalDistance()
    }
    
    // Distance report
    enum HeaderState {
        case current
        case next
    }
    
    // Distance table
    private let distanceTableView = UITableView(frame: .zero, style: .insetGrouped)
    private var distanceTableRows = [Milestone]()
    
    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
        self.distanceTableRows = Progression.getDistanceTableRows(for: distance)
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
        self.navigationItem.title = distance == 0 ? "Milestones" : "Ran: \(distance.valueShort)\(distance.metricShort)"
        distanceTableRows = Progression.getDistanceTableRows(for: distance)
        distanceTableView.reloadData()
    }
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
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
        distanceTableRows.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let fontSize = cell.textLabel?.font.pointSize ?? 17
        cell.selectionStyle = .none
        cell.backgroundColor = .shadow
        cell.textLabel?.textColor = .almostBlack
        cell.textLabel?.font = UIFont.Kefir(size: fontSize)
        cell.detailTextLabel?.font = UIFont.Kefir(size: fontSize)
        cell.detailTextLabel?.textColor = .almostBlack
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Run to see more"
            cell.textLabel?.textColor = .gray
            cell.imageView?.image = "🗺️".image(pointSize: 20).withHorizontallyFlippedOrientation()
            return cell
        }
        
        let cellInfo = distanceTableRows[indexPath.row - 1].info
        cell.textLabel?.text = cellInfo.name
        cell.imageView?.image = cellInfo.emoji.image(pointSize: 20)

        if indexPath.row == 1 {
            let color: UIColor = distance == 0 ? .pumpkin : .almostBlack
            let textString = "\(cellInfo.distance.valueShort)\(cellInfo.distance.metricShort)"
            cell.detailTextLabel?.attributedText = textString.attributedStringWithColorAndBold([textString], color: color, boldWords: [], size: fontSize)
            cell.textLabel?.attributedText = cellInfo.name.attributedStringWithColorAndBold([], color: .almostBlack, boldWords: [], size: fontSize)
        } else {
            cell.detailTextLabel?.attributedText = cellInfo.distance == 0
            ? NSAttributedString(string: "-")
            : "\(cellInfo.distance.valueShort)\(cellInfo.distance.metricShort)".strikeThrough()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let progressData = Progression.getProgressData(for: distance)
        
        let header = UIView()
        let tableWidth = view.frame.width - 32
        
        let nextLandmark = progressData.nextLandmark
        let progressPercentage = progressData.progress
        let distanceLeft = progressData.distanceLeft
        
        addProgressView()
        addDistanceLabels()
        
        return header
        
        // Progress bar with emojis
        func addProgressView() {
            let emojiView = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: 30))
            let endImage = UIImageView(image: nextLandmark.info.emoji.image(pointSize: 30))
            endImage.frame.origin = CGPoint(x: tableWidth - endImage.frame.width, y: 0)
            emojiView.addSubview(endImage)
            let progressImage = UIImageView(image: "🏃".image(pointSize: 20).withHorizontallyFlippedOrientation())
            let progressImageWidth = progressImage.frame.width
            let progressXBounded = min(tableWidth - progressImageWidth, max(0, CGFloat(progressPercentage) * tableWidth - progressImageWidth / 2))
            progressImage.frame.origin = CGPoint(x: progressXBounded, y: 10)
            emojiView.addSubview(progressImage)
            header.addSubview(emojiView)
            
            let progress = UIProgressView(frame: CGRect(x: 0, y: 40, width: tableWidth, height: 30))
            progress.setProgress(progressPercentage, animated: true)
            progress.progressTintColor = .almostBlack
            progress.trackTintColor = distance == 0 ? .darkerGray :.pumpkin
            header.addSubview(progress)
        }
        
        func addDistanceLabels() {
            let firstLabel = UILabel().setHeaderButton()
            firstLabel.frame = CGRect(x: 0, y: 60, width: tableWidth, height: 30)
            header.addSubview(firstLabel)
            
            let secondLabel = UILabel().setHeaderButton()
            secondLabel.frame = CGRect(x: 0, y: 90, width: tableWidth, height: 30)
            header.addSubview(secondLabel)
            
            if distance == 0 {
                firstLabel.text = "Start running"
                secondLabel.text = "to cross your first milestone."
                return
            } else {
                let distanceLeftvalue = "\(distanceLeft.valueShort)\(distanceLeft.metricShort)"
                let distanceLeftString = distance == 0 ? "Now put on your shoes and go do it!" :"Finish \(nextLandmark.info.name) in \(distanceLeftvalue)"
                let distanceLeftAttributedString = distanceLeftString.attributedStringWithColorAndBold([distanceLeftvalue], color: .pumpkin, boldWords: [distanceLeftString])
                firstLabel.attributedText = distanceLeftAttributedString
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return distance == 0 ? 135 : 105
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
