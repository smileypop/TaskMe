//
//  ProjectTableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/31/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import CoreData

class ProjectTableViewController : TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set the object type
        self.objectType = ObjectType.project

        // set the sort descripter
        self.sortDescriptor = ObjectAttributes.title

    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProjectTableViewCell
        let object = self.fetchedResultsController.object(at: indexPath)
        self.configureCell(cell, withObject: object)

        return cell
    }

    override func configureCell(_ cell: UITableViewCell, withObject object: Any) {

        if let project = object as? Project {

            let projectCell = cell as! ProjectTableViewCell

            projectCell.textLabel!.text = project.title!
            projectCell.completedTasksLabel!.text = "0/0"
        }
    }

    // MARK: - Detail View

    override func showDetailView(mode: String, object: NSManagedObject? = nil)
    {
        let modalViewController: ProjectDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! ProjectDetailViewController

        // we have to set mode this way to prevent compiler error : segmentation error 11
        modalViewController.viewMode = DetailViewController.ViewMode(rawValue: mode)!
        modalViewController.objectType = .project
        modalViewController.targetObject = object

        let navigationController = UINavigationController(rootViewController: modalViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        self.present(navigationController, animated: true, completion: {
            
        })
    }

}
