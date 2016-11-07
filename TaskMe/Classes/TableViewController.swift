//
//  TableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/26/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Protocol

protocol TMTableView {

    func getObjects()

    func getObject(atIndex:Int) -> Object?

    func getObjectCount() -> Int

    func configureCell(_ cell: UITableViewCell, withObject object: Object)

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell

    func showDetailView(mode: String)

    func showDetailView(mode: String, object: Object?)

}

// MARK: - Class

class TMTableViewController: UITableViewController {

    var notificationToken: NotificationToken? = nil

    // MARK: - Instance variables

    var objectType:ObjectType!
    var targetObject: Object? = nil

    var tmTableView:TMTableView!

    // MARK: - View controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set ourselves
        self.tmTableView = self as! TMTableView

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonPress(_:)))

        // TURN ON for testing
        //let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(onRefreshButtonPress(_:)))

        self.navigationItem.rightBarButtonItems = [addButton, self.editButtonItem/*, refreshButton */]

        // add error listener
        Network.errorActions.append(onNetworkError)
    }

    deinit {
        notificationToken?.stop()

        targetObject = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Realm

    func startNotifications<T>(objectList: Results<T>) {

        // Observe Results Notifications
        notificationToken = objectList.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .fade)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .fade)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .fade)
                tableView.endUpdates()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }

    func onAddButtonPress(_ sender: Any) {

        self.stopEditing()

        self.tmTableView.showDetailView(mode: DetailViewController.ViewMode.add.rawValue)
    }

    func onRefreshButtonPress(_ sender: Any) {

        // TESTING ONLY - what happens with the server has an error?
        Server.fakeError()
    }

    func onNetworkError() {

        if self is ProjectTableViewController {

            // refresh objects
            (self as! ProjectTableViewController).refreshObjects()

        } else if self is TaskTableViewController {

            // go back to Projects
            self.navigationController?.popViewController(animated: true)
        }
    }

    func updateObject(atIndexPath indexPath: IndexPath)
    {
        self.tmTableView.showDetailView(mode: DetailViewController.ViewMode.update.rawValue, object:self.tmTableView.getObject(atIndex: indexPath.row))
    }

    // Delete Confirmation and Handling
    func askToDeleteObject() {

        if let object = targetObject {

            let title:String!

            switch objectType! {

            case .project:

                title = object.value(forKey: ObjectAttribute.name.rawValue) as! String!

            case .task:

                title = object.value(forKey: ObjectAttribute.title.rawValue) as! String!
            }

            let alert = UIAlertController(title: "Delete \(self.objectType.rawValue)", message: "Are you sure you want to permanently delete \"\(title!)\"?", preferredStyle: .actionSheet)

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: deleteObject)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteObject)

            alert.addAction(deleteAction)
            alert.addAction(cancelAction)

            // Support presentation in iPad
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)

            self.present(alert, animated: true, completion: nil)
        }
    }

    func deleteObject(alertAction: UIAlertAction!) {
        if let object = targetObject {

            // if object is a project, delete all of its tasks
            switch objectType! {

            case .project:

                let project = object as! Project

                for task in (object as! Project).tasks {

                    Server.deleteTask(project_id: task.project_id, id: task.id)
                }

                Server.deleteProject(id: project.id, onSuccess: { [weak self] in

                    // remove object
                    self?.targetObject = nil
                    
                })

            case .task:

                let task = object as! Task
                
                Server.deleteTask(project_id: task.project_id, id: task.id, onSuccess: { [weak self] in

                    // remove object
                    self?.targetObject = nil

                })
                
            }

        }
    }

    func cancelDeleteObject(alertAction: UIAlertAction!) {

        // remove object
        self.targetObject = nil
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tmTableView.getObjectCount()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            // ask to delete item at indexPath

            self?.targetObject = self?.tmTableView.getObject(atIndex: indexPath.row)
            self?.askToDeleteObject()

            self?.stopEditing()
        }

        let edit = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action, indexPath) in
            // edit item at indexPath

            self?.updateObject(atIndexPath: indexPath)

            self?.stopEditing()
        }

        edit.backgroundColor = UIColor.blue

        return [delete, edit]
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    // Hide the "Edit / Delete" menu
    func stopEditing() {
        self.tableView.setEditing(false, animated: true)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if (editing) {

        } else {

        }
    }
    
}

