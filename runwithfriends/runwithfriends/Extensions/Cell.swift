//
//  Cell.swift
//  runwithfriends
//
//  Created by xavier chia on 15/11/23.
//

import UIKit

extension UITableViewCell{

    var tableView: UITableView?{
        return superview as? UITableView
    }

    var indexPath: IndexPath?{
        return tableView?.indexPath(for: self)
    }

}
