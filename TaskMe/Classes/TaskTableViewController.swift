//
//  TaskTableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/27/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class TaskTableViewController: TMTableViewController, TMTableView {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set the object type
        self.objectType = ObjectType.task

        switch self.project!.task_sort_type {
        case ObjectAttribute.deadline.rawValue:
            sortTasksSegmentedControl.selectedSegmentIndex = 1
        default:
            sortTasksSegmentedControl.selectedSegmentIndex = 0
        }
    }

    // MARK: - Custom properties

    @IBOutlet weak var sortTasksSegmentedControl: UISegmentedControl!

    var objectList: Results<Task>?

    var project: Project? {
        didSet {
            // Update the view.
            self.getObjects()
        }
    }

    // MARK: - Custom methods

    @IBAction func sortTypeChanged(sender:UISegmentedControl)
    {
        var sortType:String!

        switch sender.selectedSegmentIndex
        {
        case 0:
            sortType = ObjectAttribute.title.rawValue
        case 1:
            sortType = ObjectAttribute.deadline.rawValue
        default:
            break;
        }

        if let object = project {

            if sortType != object.task_sort_type {

                Storage.shared.update(Project.self, object.id, [ObjectAttribute.task_sort_type.rawValue : sortType])

                sortObjects(by: sortType)
            }
        }
    }

    func sortObjects(by type:String) {

        self.objectList = self.objectList?.sorted(byProperty: type)

        self.startNotifications(objectList: self.objectList!)
    }

    // MARK: - Protocol implementation

    func getObjects() {
        // Update the user interface for the detail item.

        self.objectList = Storage.shared.objects(Task.self)?.filter("\(ObjectAttribute.project_id.rawValue) == '\(self.project!.id)'").sorted(byProperty: self.project!.task_sort_type)

        self.startNotifications(objectList: self.objectList!)
    }

    func getObject(atIndex:Int) -> Object? {

        return self.objectList?[atIndex]
    }

    func getObjectCount() -> Int {

        return self.objectList?.count ?? 0
    }

    func configureCell(_ cell: UITableViewCell, withObject object: Object) {

        if let task = object as? Task {

            let taskCell = cell as! TaskTableViewCell

            taskCell.textLabel!.text = task.title
            taskCell.deadlineLabel!.text = (task.deadline as Date).toString(format: "yyyy年MM月dd日")
            taskCell.completedSwitch!.isOn = task.completed

            taskCell.task = task
        }
    }

    func showDetailView(mode: String)
    {
        self.showDetailView(mode: mode, object:nil)
    }

    func showDetailView(mode: String, object: Object? = nil)
    {
        let modalViewController: TaskDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "TaskDetail") as! TaskDetailViewController

        // we have to set mode this way to prevent compiler error : segmentation error 11
        modalViewController.viewMode = DetailViewController.ViewMode(rawValue: mode)!
        modalViewController.objectType = .task
        modalViewController.targetObject = object

        modalViewController.project = self.project

        let navigationController = UINavigationController(rootViewController: modalViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        self.present(navigationController, animated: true, completion: {

            modalViewController.showDoneButton()
            
        })
    }

    // MARK: - Class overrides

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskTableViewCell

        if let object = self.getObject(atIndex: indexPath.row) {
            self.configureCell(cell, withObject: object)
        }

        return cell
    }
    
}
