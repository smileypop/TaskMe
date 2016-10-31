//
//  TaskTableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/27/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: UITableViewController {

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Set appropriate labels for the cells.
        if (indexPath as NSIndexPath).row == 0 {
            cell.textLabel?.text = "Fake 1"
        }
        else {
            cell.textLabel?.text = "Fake 2"
        }

        return cell
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            let controller = (segue.destination as! UINavigationController).topViewController as! TaskDetailViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.view.backgroundColor = UIColor.purple
        
    }
    
}
