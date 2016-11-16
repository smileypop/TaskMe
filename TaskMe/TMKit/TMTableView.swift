//
//  TableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/26/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - TMTableViewControllerDelegate

protocol TMTableViewControllerDelegate: class {

    func getObjects()

    func getObject(atIndex:Int) -> Object?

    func getObjectCount() -> Int

    func getTitle(for object: Object) -> String

    func deleteObject(_: UIAlertAction!)

    func configureCell(_ cell: UITableViewCell, withObject object: Object)

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell

    func createDetailView() -> TMDetailViewController

    func onNetworkError()

}

// MARK: - TMTableViewController

class TMTableViewController: UITableViewController  {

    // MARK: - Properties

    var delegate:TMTableViewControllerDelegate!                 // delegate

    internal var notificationToken: NotificationToken? = nil    // listener for object changes
    internal var objectType:CustomObject.Entity!                // the type of objects listed in this table
    internal var targetObject: Object? = nil                    // the object user has selected for "edit / delete"

    private var networkErrorObserver: NSObjectProtocol!         // network error listener
    private var userInteractionObserver: NSObjectProtocol!      // user interaction listener

    // MARK: - Controller methods

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.

        // set ourselves
        self.delegate = self as! TMTableViewControllerDelegate

        // add error listener
        networkErrorObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Network.ResponseNotification.error.rawValue),
                                                                         object: nil,
                                                                         queue: OperationQueue.main) { [weak self] notification in
                                                                            self?.delegate?.onNetworkError()
        }

        // add user interaction listener
        userInteractionObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: UIHelper.UserInteractionNotification.enabled.rawValue),
                                                                         object: nil,
                                                                         queue: OperationQueue.main) { [weak self] notification in
                                                                            self?.setUserInteraction(enabled: true)
        }

        // set up navigation items
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonPress(_:)))

        self.navigationItem.rightBarButtonItems = [addButton, self.editButtonItem]
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)

        if parent == nil {

            cleanup()
        }
    }

    func cleanup() {

        // clear listeners
        if self.networkErrorObserver != nil {
            NotificationCenter.default.removeObserver(networkErrorObserver)
            self.networkErrorObserver = nil
        }

        if self.userInteractionObserver != nil {
            NotificationCenter.default.removeObserver(userInteractionObserver)
            self.userInteractionObserver = nil
        }

        // stop listening for changes
        self.notificationToken?.stop()

        // clear the target object
        self.targetObject = nil

        // clear the delegate
        self.delegate = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Custom methods

    // Enable / Disable menu when a Detail view is showing
    func setUserInteraction(enabled: Bool) {

        // check the window hierarchy
        if self.view.window != nil {

            self.view.isUserInteractionEnabled = enabled
            self.view.alpha = enabled ? 1.0 : 0.5

            self.navigationController?.navigationBar.isUserInteractionEnabled = enabled;
            self.navigationController?.navigationBar.alpha = enabled ? 1.0 : 0.5
        }
    }

    // User has chosen to add or edit an object - show a detail view
    func showDetailView(mode: String, object: Object? = nil)
    {

        // create the correct detail view
        let modalViewController = self.delegate.createDetailView()

        // we have to set mode this way to prevent compiler error : segmentation error 11
        modalViewController.viewMode = TMDetailViewController.ViewMode(rawValue: mode)!
        modalViewController.objectType = self.objectType
        modalViewController.targetObject = object

        // pop the alert over current context
        let navigationController = UINavigationController(rootViewController: modalViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        // disable the table menu
        self.setUserInteraction(enabled: false)

        let onCompleteAction = {

            // show the done button after the view is ready
            modalViewController.showDoneButton()
        }

        // on iPad - pop over empty view
        if (UIDevice.current.userInterfaceIdiom == .pad) {

            // present the detail view
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            appDelegate.topViewController.present(navigationController, animated: true, completion: onCompleteAction)

        } else {

            // pop over current view
            self.present(navigationController, animated: true, completion: onCompleteAction)
        }

    }

    // User wants to add an object
    func onAddButtonPress(_ sender: Any) {

        self.stopEditing()

        self.showDetailView(mode: TMDetailViewController.ViewMode.add.rawValue)
    }

    // User wants to update an object
    func updateObject(atIndexPath indexPath: IndexPath)
    {
        self.showDetailView(mode: TMDetailViewController.ViewMode.update.rawValue, object:self.delegate.getObject(atIndex: indexPath.row))
    }

    // Delete Confirmation and Handling
    func askToDeleteObject(at indexPath: IndexPath) {

        if let object = targetObject {

            // get the name of the object
            let title = self.delegate.getTitle(for: object)

            // show a title
            let alert = UIAlertController(title: "Delete \(self.objectType.rawValue)", message: "Are you sure you want to permanently delete \"\(title)\"?", preferredStyle: .actionSheet)

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: delegate.deleteObject)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteObject)

            alert.addAction(deleteAction)
            alert.addAction(cancelAction)

            // Support presentation in iPad
            alert.popoverPresentationController?.sourceView = self.view

            // on iPad - point to the object row
            if (UIDevice.current.userInterfaceIdiom == .pad) {

                alert.popoverPresentationController?.sourceRect = self.tableView.rectForRow(at: indexPath)

            } else {

                // show popup at bottom of the screen
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
            }

            self.present(alert, animated: true, completion: nil)
        }
    }

    func cancelDeleteObject(_: UIAlertAction!) {

        // remove object
        self.targetObject = nil
    }

    // Hide the "Edit / Delete" menu
    func stopEditing() {

        self.setEditing(false, animated: true)
    }

    // MARK: - Table View protocol methods

    override func numberOfSections(in tableView: UITableView) -> Int {

        // we only have 1 section
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // get the number of objects
        return self.delegate.getObjectCount()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // we need this delegate method to allow table cell editing
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        // Show an Edit / Delete menu if the user swipes right to left on a table row

        // User tapped Delete
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in

            self?.targetObject = self?.delegate.getObject(atIndex: indexPath.row)

            // ask for confirmation before deleting
            self?.askToDeleteObject(at: indexPath)
        }

        // User tapped Edit
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action, indexPath) in
            // edit item at indexPath

            // show the Edit detail veiew
            self?.updateObject(atIndexPath: indexPath)
        }

        // set a blue background for the Edit button
        edit.backgroundColor = UIColor.blue

        return [delete, edit]
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    // User wants to start / stop editing
    override func setEditing(_ editing: Bool, animated: Bool) {

        // tell super
        super.setEditing(editing, animated: animated)

        // tell tableview
        self.tableView.setEditing(editing, animated: animated)

        // add custom code
        if (editing) {

        } else {

        }
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
    
}

