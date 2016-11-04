//
//  TaskDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/26/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class TaskDetailViewController: DetailViewController {

    @IBOutlet weak var deadlineDatePicker: UIDatePicker!

    var project:Project!

    override func setup() {

        if let object:Task = self.targetObject as? Task {

            self.nameTextField.text = object.name

            self.deadlineDatePicker.date = object.deadline as Date

        } else {

            // set the minimum date to today
            self.deadlineDatePicker.minimumDate = Date()
        }

    }

    // MARK: Objects

    override func addObject() {

//        if let object:Task = Storage.shared.createEntity(entityName: self.objectType.rawValue) as? Task {
//
//            setValues(for: object)
//        }

        let object = Task()

        object.id = Models.getIdForNewObject(self.objectType)

        object.project_id = self.project.id

        // add this taks to the project tasks
        Storage.shared.append(object, self.project.tasks)

        setValues(for: object)

        dismissSelf()
    }

    override func updateObject() {

        if let object = self.targetObject as? Task {

            setValues(for: object)
        }
        
        dismissSelf()
    }

    func setValues(for object: Task)
    {
        //object.name = self.objectName

        //object.deadline = self.deadlineDatePicker.date as NSDate

        Storage.shared.add(object, [
            "name" : self.objectName,
            "deadline" : self.deadlineDatePicker.date as NSDate
            ])

        //Storage.shared.save()

    }

}
