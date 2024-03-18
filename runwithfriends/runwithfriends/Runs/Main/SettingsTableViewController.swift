//
//  SettingsTableViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 16/3/24.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    enum AccessoryViewType: String {
        case toggle, detail
    }
    
    struct Section {
        let title: String
        let cells: [CellInfo]
    }
    
    struct CellInfo {
        let runSetting: UserDefaults.RunSettings
        let type: AccessoryViewType
    }
    
    private let tableData: [Section] = [
        Section(title: "Audio",
                cells: [
                    CellInfo(runSetting: .runAudio, type: .toggle)
                ]),
        Section(title: "Before and after run",
                cells: [
                    CellInfo(runSetting: .runStart, type: .toggle),
                    CellInfo(runSetting: .runComplete, type: .toggle)
                ]),
        Section(title: "During run",
                cells: [
                    CellInfo(runSetting: .runTime, type: .toggle),
                    CellInfo(runSetting: .runDistance, type: .toggle),
                    CellInfo(runSetting: .runFrequency, type: .detail)
                ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cream
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableData[section].title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = tableData[indexPath.section].cells[indexPath.row].runSetting.label
        cell.textLabel?.textColor = .almostBlack
        cell.backgroundColor = .shadow
        cell.selectionStyle = .none
        
        let cellInfo = tableData[indexPath.section].cells[indexPath.row]
        setAccessoryView(for: cell, with: cellInfo)
        disableAudioOptionsIfNeeded(for: cell, with: cellInfo)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .black
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
    }
    
    private func setAccessoryView(for cell: UITableViewCell, with cellInfo: CellInfo) {
        switch cellInfo.type {
        case .toggle:
            let switchView = UISwitch(frame: .zero)
            let isSwitchOn = UserDefaults.standard.bool(forKey: cellInfo.runSetting.rawValue)
            switchView.setOn(isSwitchOn, animated: true)
            switchView.accessibilityIdentifier = cellInfo.runSetting.rawValue
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case .detail:
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    private func disableAudioOptionsIfNeeded(for cell: UITableViewCell, with cellInfo: CellInfo) {
        if RunSettings.runAudio == false && cellInfo.runSetting != .runAudio {
            cell.contentView.alpha = 0.5
            cell.isUserInteractionEnabled = false
            if let switchView = cell.accessoryView as? UISwitch {
                switchView.isEnabled = false
            }
        }
    }
    
    @objc private func switchChanged(_ sender : UISwitch!) {
        if let accessibilityIdentifier = sender.accessibilityIdentifier,
           let runSetting = UserDefaults.RunSettings(rawValue: accessibilityIdentifier) {
            switch runSetting {
            case .runAudio:
                RunSettings.runAudio = sender.isOn
                tableView.reloadSections(IndexSet(integersIn: 1...2), with: .automatic)
            case .runStart:
                RunSettings.runStart = sender.isOn
            case .runComplete:
                RunSettings.runComplete = sender.isOn
            case .runTime:
                RunSettings.runTime = sender.isOn
            case .runDistance:
                RunSettings.runDistance = sender.isOn
            case .isSetup, .runFrequency:
                break
            }
        }
    }
}
