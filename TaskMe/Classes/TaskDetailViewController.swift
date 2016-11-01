//
//  TaskDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/26/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit

class TaskDetailViewController: DetailViewController {

    @IBOutlet weak var deadlineDatePicker: UIDatePicker!

    override func setup() {

        if let object:Task = self.targetObject as? Task {

            self.titleTextField.text = object.title

            self.deadlineDatePicker.date = object.deadline as! Date

        } else {

            // set the minimum date to today
            self.deadlineDatePicker.minimumDate = Date()
        }

    }

    // MARK: Objects

    override func addObject() {

        if let object:Task = Storage.shared.createEntity(entityName: self.objectType.rawValue) as? Task {

            setValues(for: object)
        }

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
        object.title = self.objectTitle

        object.deadline = self.deadlineDatePicker.date as NSDate

        Storage.shared.save()

    }

}
