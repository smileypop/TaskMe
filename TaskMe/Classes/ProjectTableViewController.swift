//
//  ProjectTableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/31/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectTableViewController : TMTableViewController, TMTableViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set the object type
        self.objectType = CustomObject.Entity.project

        // get a list of all projects
        self.getObjects()
    }

    // MARK: - Custom properties

    var objectList: Results<Project>?

    // MARK: - Custom methods

    // called if there is a Network error
    func refreshObjects() {

        // remeve all Realm objects
        Storage.shared.deleteAll( {

            // call the server - refresh the objects
            Server.getProjects()

        })
    }

    // get the number of completed tasks for this project
    func getNumberOfCompletedTasks(_ project:Project) -> Int {

        var numberOfCompletedTasks = 0

        // loop through each task
        for task in project.tasks {

            if task.completed {

                numberOfCompletedTasks += 1
            }
        }

        return numberOfCompletedTasks
    }

    // MARK: - Protocol implementations

    func getObjects() {

        // get a list of objects
        self.objectList = Storage.shared.objects(Project.self)

        // listen for changes
        self.startNotifications(objectList: self.objectList!)

        // call the server
        Server.getProjects()

    }

    func getObject(atIndex: Int) -> Object? {

        return self.objectList?[atIndex]
    }

    // get the total number of projects
    func getObjectCount() -> Int {

        return self.objectList?.count ?? 0
    }

    func deleteObject(_: UIAlertAction!) {

        if let project = targetObject as? Project {

            // delete all tasks under this project
            for task in project.tasks {

                Server.deleteTask(project_id: task.project_id, id: task.id)
            }

            // delete the project on the server
            Server.deleteProject(id: project.id, onSuccess: { [weak self] in

                // remove object
                self?.targetObject = nil

            })
        }
    }

    // return the name of the project
    func getTitle(for object: Object) -> String {

        return object.value(forKey: CustomObject.Attribute.name.rawValue) as! String!
    }

    func configureCell(_ cell: UITableViewCell, withObject object: Object) {

        if let project = object as? Project {

            let projectCell = cell as! ProjectTableViewCell

            // show the project name
            projectCell.titleLabel!.text = project.name

            // show the number of completed tasks example: 3/5
            projectCell.completedTasksLabel!.text = "\(self.getNumberOfCompletedTasks(project)) / \(project.tasks.count)"
        }
    }

    // Add / Edit project
    func createDetailView() -> TMDetailViewController {

        let detailView = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! TMDetailViewController

        return detailView
    }

    // called when the Network fails
    func onNetworkError() {

        // refresh objects
        self.refreshObjects()

    }

    // MARK: - TMTableViewController methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProjectTableViewCell

        // setup the cell contents
        if let object = self.getObject(atIndex: indexPath.row) {
            self.configureCell(cell, withObject: object)
        }

        return cell
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // we are moving to the Tasks list
        if segue.identifier == "showTaskTableView" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let destination = segue.destination as! TaskTableViewController
                
                // set the project owner of the task
                if let object = getObject(atIndex: indexPath.row) as? Project {
                    
                    destination.project = object
                    
                }
            }
        }
    }
    
}
