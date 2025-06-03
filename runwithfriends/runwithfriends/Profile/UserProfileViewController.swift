//
//  UserProfileViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 6/11/23.
//

import UIKit
import SharedCode

class UserProfileViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var userData: UserData
    private var username: String
    
    private let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._- ")
    
    enum Title {
        static let username = "Username"
        static let emoji = "Emoji"
        static let id = "ID"
        static let deleteAccount = "Delete account"
    }
    
    struct CellData {
        let title: String
        let subtitle: String?
        let isEditable: Bool
        
        init(title: String, subtitle: String, isEditable: Bool) {
            self.title = title
            self.subtitle = subtitle
            self.isEditable = isEditable
        }
        
        init(title: String, isEditable: Bool) {
            self.title = title
            self.subtitle = nil
            self.isEditable = isEditable
        }
    }
    
    private var tableCellTitles = [[CellData]]()
    
    init(with userData: UserData) {
        self.userData = userData
        self.username = userData.user.username
        
        tableCellTitles = [
            [
                CellData(title: Title.username, subtitle: userData.user.username, isEditable: true),
                CellData(title: Title.emoji, subtitle: userData.user.emoji, isEditable: false),
                CellData(title: Title.id, subtitle: String(userData.user.search_id), isEditable: false)
            ],
            [
                CellData(title: Title.deleteAccount, isEditable: true)
            ]
        ]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseBackground
        setupNavigationController()
        setupTableView()
    }
    
    // MARK: - Setup UI
    
    private func setupNavigationController() {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .baseBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Username Edit
    
    private func presentUsernameEditAlert() {
        let alert = UIAlertController(title: "Change Username", message: "Max 7 characters", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.username
            textField.placeholder = "Enter username"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.clearButtonMode = .whileEditing
            
            // Set up character limit
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let textField = alert.textFields?.first,
               let newUsername = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !newUsername.isEmpty,
               newUsername != self.username {
                self.updateUsername(newUsername)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        // Filter out characters not in the allowed character set
        let filteredText = text.unicodeScalars.filter { allowedCharacterSet.contains($0) }
        let filteredString = String(filteredText)
        
        // Limit to 7 characters
        let finalText = filteredString.count > 7 ? String(filteredString.prefix(7)) : filteredString
        
        textField.text = finalText
    }
    
    private func updateUsername(_ newUsername: String) {
        // Show loading state
        let loadingAlert = UIAlertController(title: "Updating...", message: "Please wait", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        Task {
            let success = await userData.updateUsername(newUsername)
            
            await MainActor.run {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        // Update local UI with the new username from userData.user
                        self.username = self.userData.user.username
                        self.tableCellTitles[0][0] = CellData(title: Title.username, subtitle: self.userData.user.username, isEditable: true)
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                        
                        // Update parent ProfileViewController's navigation title for back button
                        if let profileVC = self.navigationController?.viewControllers.first(where: { $0 is ProfileViewController }) as? ProfileViewController {
                            profileVC.navigationItem.title = self.userData.user.username
                        }
                        
                        // Show success message
                        let successAlert = UIAlertController(title: "Success", message: "Username updated successfully", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(successAlert, animated: true)
                    } else {
                        // Show error message
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to update username. Please try again.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
    
    private func showDeleteAccountAlert() {
        let alert = UIAlertController(title: "Delete Account", message: "This action cannot be undone. Type 'DELETE' to confirm.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Type DELETE to confirm"
            textField.autocapitalizationType = .allCharacters
            textField.autocorrectionType = .no
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            if let textField = alert.textFields?.first,
               let confirmationText = textField.text,
               confirmationText.uppercased() == "DELETE" {
                self.deleteAccount()
            } else {
                // Show error if confirmation doesn't match
                let errorAlert = UIAlertController(title: "Confirmation Required", message: "You must type 'DELETE' to confirm account deletion.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    private func deleteAccount() {
        // Show loading state
        let loadingAlert = UIAlertController(title: "Deleting...", message: "Please wait", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        Task {
            let success = await userData.deleteAccount()
            
            await MainActor.run {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        // Show success message
                        let successAlert = UIAlertController(title: "Success", message: "Account deleted successfully", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
                            if let window = self.view.window {
                                window.rootViewController = LoginViewController()
                                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
                            }
                        }))
                        self.present(successAlert, animated: true)
                    } else {
                        // Show error message
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to delete account. Please try again.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableCellTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCellTitles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellIdentifier")
        let cellData = tableCellTitles[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellData.title
        cell.detailTextLabel?.text = cellData.subtitle
        cell.accessoryType = cellData.isEditable ? .disclosureIndicator : .none
        cell.isUserInteractionEnabled = cellData.isEditable ? true : false
        cell.backgroundColor = .shadow
        cell.textLabel?.textColor = .baseText
        cell.textLabel?.font = UIFont.QuicksandMedium(size: 16)
        cell.detailTextLabel?.font = UIFont.QuicksandMedium(size: 16)
        cell.detailTextLabel?.textColor = .secondaryText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellData = tableCellTitles[indexPath.section][indexPath.row]
        guard cellData.isEditable else {
            return
        }
        
        switch cellData.title {
        case Title.username:
            presentUsernameEditAlert()
        case Title.deleteAccount:
            showDeleteAccountAlert()
        default:
            print("do nothing")
        }
    }
}
