//
//  RunsViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 2/11/23.
//

import UIKit

class RunsViewController: UIViewController {
    let runsTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()

        runsTableView.delegate = self
        runsTableView.dataSource = self
        runsTableView.backgroundColor = .black
        view.addSubview(runsTableView)
        runsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            runsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            runsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            runsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            runsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
//        setupSegmentControl()
    }
    
    // MARK: SetupUI
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "5K Runs"
    }
    
    private func setupSegmentControl() {
        let segmentStackView = UISegmentStackView()
        segmentStackView.delegate = self
        view.addSubview(segmentStackView)

        let leftMargin = navigationController!.systemMinimumLayoutMargins.leading
        let rightMargin = navigationController!.systemMinimumLayoutMargins.trailing
        
        NSLayoutConstraint.activate([
            segmentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftMargin),
            segmentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -rightMargin),
            segmentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension RunsViewController: UISegmentStackViewProtocol {
    func runsButtonPressed() {
        print("runs button pressed in vc")
    }
    
    func unlockedButtonPressed() {
        print("unlocked button pressed in vc")
    }
}



extension RunsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
            
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        label.text = "HEHIEE"
        label.textColor = .white
//        headerView.addSubview(label)
        return label
    }
    
    
}
