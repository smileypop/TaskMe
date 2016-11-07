//
//  ProjectTableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/31/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectTableViewController : TMTableViewController, TMTableView {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set the object type
        self.objectType = ObjectType.project

        self.getObjects()

        print("ProjectTableViewController viewDidLoad")
    }

    // MARK: - Custom properties

    var objectList: Results<Project>?

    // MARK: - Custom methods

    func getNumberOfCompletedTasks(_ project:Project) -> Int {

        var numberOfCompletedTasks = 0

        for task in project.tasks {

            if task.completed {

                numberOfCompletedTasks += 1
            }
        }

        return numberOfCompletedTasks
        
    }

    // MARK: - Protocol implementations

    func getObjects() {

        self.objectList = Storage.shared.objects(Project.self)

        self.startNotifications(objectList: self.objectList!)

        Server.getProjects()

    }

    func refreshObjects() {

        print("refreshObjects")

        Storage.shared.deleteAll( {

            Server.getProjects()
            
        })
    }

    func getObject(atIndex:Int) -> Object? {

        return self.objectList?[atIndex]
    }

    func getObjectCount() -> Int {

        return self.objectList?.count ?? 0
    }
    func configureCell(_ cell: UITableViewCell, withObject object: Object) {

        if let project = object as? Project {

            let projectCell = cell as! ProjectTableViewCell

            projectCell.titleLabel!.text = project.name
            projectCell.completedTasksLabel!.text = "\(self.getNumberOfCompletedTasks(project)) / \(project.tasks.count)"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProjectTableViewCell

        if let object = self.getObject(atIndex: indexPath.row) {
            self.configureCell(cell, withObject: object)
        }

        return cell
    }

    func showDetailView(mode: String)
    {
        self.showDetailView(mode: mode, object:nil)
    }

    func showDetailView(mode: String, object: Object?)
    {
        let modalViewController: ProjectDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectDetail") as! ProjectDetailViewController

        // we have to set mode this way to prevent compiler error : segmentation error 11
        modalViewController.viewMode = DetailViewController.ViewMode(rawValue: mode)!
        modalViewController.objectType = .project
        modalViewController.targetObject = object

        let navigationController = UINavigationController(rootViewController: modalViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

        // hide menu for iPad
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            appDelegate.splitViewController.preferredDisplayMode = .primaryHidden

        }

        // Choose view based on iPhone or iPad
        appDelegate.getTopViewController().present(navigationController, animated: true, completion: {

            modalViewController.showDoneButton()

        })
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTaskTableView" {
            if let indexPath = self.tableView.indexPathForSelectedRow {

                let destination = segue.destination as! TaskTableViewController

                if let object = getObject(atIndex: indexPath.row) as? Project {

                    destination.project = object

                }
            }
        }
    }

}
