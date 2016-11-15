//
//  TaskTableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/27/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class TaskTableViewController: TMTableViewController, TMTableViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set the object type
        self.objectType = CustomObject.Entity.task

        // show the correct sort options
        switch self.project!.task_sort_type {
        case CustomObject.Attribute.deadline.rawValue:
            sortTasksSegmentedControl.selectedSegmentIndex = 1
        default:
            sortTasksSegmentedControl.selectedSegmentIndex = 0
        }
    }

    // MARK: - Custom properties

    @IBOutlet weak var sortTasksSegmentedControl: UISegmentedControl!

    var objectList: Results<Task>?

    // the project owner for this task
    var project: Project? {
        didSet {
            if (project != nil) {
                // Update the view.
                self.getObjects()
            }
        }
    }

    // MARK: - Custom methods

    // The user clicked the Tasks Sort Control - change the sort type
    @IBAction func sortTypeChanged(sender:UISegmentedControl)
    {
        var sortType:String!

        switch sender.selectedSegmentIndex
        {
        case 0:
            sortType = CustomObject.Attribute.title.rawValue
        case 1:
            sortType = CustomObject.Attribute.deadline.rawValue
        default:
            break;
        }

        // save the sort type to disk
        if let object = project {

            if sortType != object.task_sort_type {

                Storage.shared.update(Project.self, object.id, [CustomObject.Attribute.task_sort_type.rawValue : sortType])

                sortObjects(by: sortType)
            }
        }
    }

    // sort the tasks by their Title or Deadline
    func sortObjects(by type:String) {

        self.objectList = self.objectList?.sorted(byProperty: type)

        self.startNotifications(objectList: self.objectList!)
    }

    // MARK: - Protocol implementation

    func getObjects() {

        // get all tasks in the parent project
        self.objectList = Storage.shared.objects(Task.self)?.filter("\(CustomObject.Attribute.project_id.rawValue) == '\(self.project!.id)'").sorted(byProperty: self.project!.task_sort_type)

        // listen for changes
        self.startNotifications(objectList: self.objectList!)
    }

    func getObject(atIndex:Int) -> Object? {

        return self.objectList?[atIndex]
    }

    func getObjectCount() -> Int {

        return self.objectList?.count ?? 0
    }

    func deleteObject(_: UIAlertAction!) {

        if let task = targetObject as? Task {

            // Server - delete task
            Server.deleteTask(project_id: task.project_id, id: task.id, onSuccess: { [weak self] in

                // remove object
                self?.targetObject = nil

            })
        }
    }

    // get the title for this task
    func getTitle(for object: Object) -> String {

        return object.value(forKey: CustomObject.Attribute.title.rawValue) as! String!
    }

    // setup the cell view
    func configureCell(_ cell: UITableViewCell, withObject object: Object) {

        if let task = object as? Task {

            let taskCell = cell as! TaskTableViewCell

            taskCell.titleLabel!.text = task.title
            taskCell.deadlineLabel!.text = (task.deadline as Date).toString(format: "yyyy/MM/dd")
            taskCell.completedSwitch!.isOn = task.completed

            // set a reference to this task
            taskCell.task = task
        }
    }

    // User wants to Add / Edit a task - show the detail view
    func createDetailView() -> TMDetailViewController {

        let detailView = self.storyboard?.instantiateViewController(withIdentifier: "TaskDetail") as! TMDetailViewController

        // set a reference to the parent project
        (detailView as! TaskDetailViewController).project = self.project

        return detailView
    }

    func onNetworkError() {

        // go back to Projects
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - TMTableViewController methods

    override func cleanup() {
        super.cleanup()

        self.objectList = nil
        self.project = nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskTableViewCell

        if let object = self.getObject(atIndex: indexPath.row) {
            self.configureCell(cell, withObject: object)
        }

        return cell
    }
    
}
