//
//  ProjectTableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/31/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectTableViewController : TableViewController {

    var objectList: Results<Project>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set the object type
        self.objectType = ObjectType.project

        self.objectList = Storage.shared.objects(Project.self)

        self.startNotifications(objectList: self.objectList!)

    }

    // MARK: - Objects

    override func getObjectCount() -> Int {

        return self.objectList?.count ?? 0
    }

    override func getObject(atIndex:Int) -> Project? {

        return self.objectList?[atIndex]
    }

    func getNumberOfCompletedTasks(_ project:Project) -> Int {

        var numberOfCompletedTasks = 0

        for task in project.tasks {

            if task.completed {

                numberOfCompletedTasks += 1
            }
        }

        return numberOfCompletedTasks
        
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProjectTableViewCell
        //let object = self.fetchedResultsController.object(at: indexPath)
        if let object = self.getObject(atIndex: indexPath.row) {
            self.configureCell(cell, withObject: object)
        }

        return cell
    }

    override func configureCell(_ cell: UITableViewCell, withObject object: Object) {

        if let project = object as? Project {

            let projectCell = cell as! ProjectTableViewCell

            projectCell.textLabel!.text = project.name
            projectCell.completedTasksLabel!.text = "\(self.getNumberOfCompletedTasks(project)) / \(project.tasks.count)"
        }
    }

    // MARK: - Detail View

    override func showDetailView(mode: String, object: Object? = nil)
    {
        let modalViewController: ProjectDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! ProjectDetailViewController

        // we have to set mode this way to prevent compiler error : segmentation error 11
        modalViewController.viewMode = DetailViewController.ViewMode(rawValue: mode)!
        modalViewController.objectType = .project
        modalViewController.targetObject = object

        let navigationController = UINavigationController(rootViewController: modalViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        self.present(navigationController, animated: true, completion: {

            modalViewController.showDoneButton()
            
        })
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTaskTableView" {
            if let indexPath = self.tableView.indexPathForSelectedRow {

                let destination = segue.destination as! TaskTableViewController

                if let object = getObject(atIndex: indexPath.row) {

                    destination.project = object

                }
            }
        }
    }

}
