//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit

struct CellData {
    let time: String
    let amOrPm: String
    let runners: String
    let canJoin: Bool
}

class RunsViewController: UIViewController {
    let runsTableView = UITableView(frame: .zero, style: .grouped)
    let segmentStackView = UISegmentStackView(leftTitle: "Upcoming", rightTitle: "Unlocked")
        
    let data = [
        CellData(time: "11:00", amOrPm: "AM", runners: "25 / 25 runners", canJoin: false),
        CellData(time: "11:30", amOrPm: "AM", runners: "25 / 25 runners", canJoin: false),
        CellData(time: "12:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
        CellData(time: "12:30", amOrPm: "PM", runners: "20 / 25 runners", canJoin: true),
        CellData(time: "1:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
        CellData(time: "1:30", amOrPm: "PM", runners: "25 / 25 runners", canJoin: false),
        CellData(time: "2:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
        CellData(time: "2:30", amOrPm: "PM", runners: "25 / 25 runners", canJoin: false),
        CellData(time: "3:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
        CellData(time: "3:30", amOrPm: "PM", runners: "12 / 25 runners", canJoin: true),
        CellData(time: "4:00", amOrPm: "PM", runners: "15 / 25 runners", canJoin: true),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        segmentStackView.delegate = self
        setupRunsTableView()
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
        runsTableView.separatorColor = .darkGray
        runsTableView.showsVerticalScrollIndicator = false
        runsTableView.register(UINib(nibName: "UIRunTableViewCell", bundle: nil), forCellReuseIdentifier: "UIRunTableViewCell")

        view.addSubview(runsTableView)
        runsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            runsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            runsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            runsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            runsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension RunsViewController: UISegmentStackViewProtocol {
    func leftButtonPressed() {
        print("runs button pressed in vc")
    }
    
    func rightButtonPressed() {
        print("unlocked button pressed in vc")
    }
}

extension RunsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == runsTableView,
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIRunTableViewCell") as? UIRunTableViewCell {
            cell.configure(with: data[indexPath.row])
            return cell
        }

        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
            
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        segmentStackView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        return segmentStackView
    }
}
