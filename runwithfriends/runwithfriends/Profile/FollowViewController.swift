//
//  FollowViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 5/4/25.
//

import UIKit

class FollowViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    // Initialize with searchResultsController set to nil
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
        
        // Configure the search controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        // Set delegates
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = true
        
        // Critical property for proper dismissal
        definesPresentationContext = true
        
        // Setup navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "Following"
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchController.searchBar.showsCancelButton = true
//    }
}
