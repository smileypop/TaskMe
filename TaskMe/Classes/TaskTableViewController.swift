//
//  TaskTableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/27/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import CoreData

// custom date formatter
extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

class TaskTableViewController: TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set the object type
        self.objectType = ObjectType.task

        // set the sort descripter
        self.sortDescriptor = ObjectAttributes.title

    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskTableViewCell
        let object = self.fetchedResultsController.object(at: indexPath)
        self.configureCell(cell, withObject: object)

        return cell
    }

    override func configureCell(_ cell: UITableViewCell, withObject object: Any) {

        if let task = object as? Task {

            let taskCell = cell as! TaskTableViewCell

            taskCell.textLabel!.text = task.title
            taskCell.deadlineLabel!.text = (task.deadline as! Date).toString(format: "yyyy-MM-dd")
            taskCell.completedSwitch!.isOn = task.isComplete
        }
    }

    // MARK: - Detail View

    override func showDetailView(mode: String, object: NSManagedObject? = nil)
    {
        let modalViewController: TaskDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "TaskDetail") as! TaskDetailViewController

        // we have to set mode this way to prevent compiler error : segmentation error 11
        modalViewController.viewMode = DetailViewController.ViewMode(rawValue: mode)!
        modalViewController.objectType = .task
        modalViewController.targetObject = object

        let navigationController = UINavigationController(rootViewController: modalViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.present(navigationController, animated: true, completion: {
            
        })
    }
    
}
