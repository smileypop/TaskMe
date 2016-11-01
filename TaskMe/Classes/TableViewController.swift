//
//  TableViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/26/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Protocol Methods

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Class properties

    enum ObjectType: String {
        case project = "Project"
        case task = "Task"
    }

    enum ObjectAttributes: String {
        case title
        case deadline
    }

    // MARK: - Instance variables

    var targetObject: NSManagedObject? = nil
    var objectType:ObjectType!
    var sortDescriptor:ObjectAttributes!

    // MARK: - View controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonPress(_:)))
        self.navigationItem.rightBarButtonItem = addButton

    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onAddButtonPress(_ sender: Any) {

        self.stopEditing()

        self.showDetailView(mode: DetailViewController.ViewMode.add.rawValue)
    }

    // MARK: - Methods to override in subclass

    func showDetailView(mode: String, object: NSManagedObject? = nil) {

    }

    // MARK: - Objects

    func updateObject(atIndexPath indexPath: IndexPath)
    {
        self.showDetailView(mode: DetailViewController.ViewMode.update.rawValue, object:self.fetchedResultsController.object(at: indexPath) as? NSManagedObject)
    }

    // Delete Confirmation and Handling
    func askToDeleteObject() {

        if let object = targetObject {

            let title = object.value(forKey: ObjectAttributes.title.rawValue)

            let alert = UIAlertController(title: "Delete \(self.objectType.rawValue)", message: "Are you sure you want to permanently delete \"\(title)\"?", preferredStyle: .actionSheet)

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: deleteObject)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: finishDeleteObject)

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
            context.delete(object)

            //saveContext()

            Storage.shared.save()

            // remove object
            targetObject = nil
        }
    }

    func finishDeleteObject(alertAction: UIAlertAction!) {
        targetObject = nil
    }

    // MARK: - Object Context

    lazy var context: NSManagedObjectContext = {
        return Storage.shared.context
    }()

//    var context: NSManagedObjectContext {
//        get {
//            return self.fetchedResultsController.managedObjectContext
//        }
//    }

    func saveContext() {

        if context.hasChanges {
            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }

    //    override func setEditing(_ editing: Bool, animated: Bool) {
    //        super.setEditing(editing, animated: animated)
    //        tableView.reloadData()
    //    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            // ask to delete item at indexPath
            self?.targetObject = self?.fetchedResultsController.object(at: indexPath) as? NSManagedObject
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

    func configureCell(_ cell: UITableViewCell, withObject object: Any) {}

    // Hide the "Edit / Delete" menu
    func stopEditing() {
        self.tableView.setEditing(false, animated: true)
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: objectType.rawValue)

        // Set the batch size to a suitable number.
        //fetchRequest.fetchBatchSize = 100

        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: self.sortDescriptor.rawValue, ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptor]

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Storage.shared.context, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController

        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, withObject: anObject)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     self.tableView.reloadData()
     }
     */
    
}

