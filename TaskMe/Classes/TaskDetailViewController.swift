//
//  TaskDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/26/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class TaskDetailViewController: DetailViewController, TMDetailView {

    // MARK: - Custom properties

    @IBOutlet weak var deadlineDatePicker: UIDatePicker!

    var project:Project!

    // MARK: - TMDetailView protocol

    func setup() {

        if let object:Task = self.targetObject as? Task {

            self.nameTextField.text = object.title

            self.deadlineDatePicker.date = object.deadline as Date

        } else {

            // set the minimum date to today
            self.deadlineDatePicker.minimumDate = Date()
        }

    }

    func addObject() {

            let deadline = Int(floor(self.deadlineDatePicker.date.timeIntervalSince1970))

            Server.postTask(project_id: self.project.id, title: self.objectName, deadline: deadline, onSuccess: dismissSelf)
    }

    func updateObject() {

        if let object = self.targetObject as? Task {

            let deadline = Int(floor(self.deadlineDatePicker.date.timeIntervalSince1970))
            
            Server.patchTask(project_id: object.project_id, id: object.id, title: self.objectName, deadline: deadline, onSuccess: dismissSelf)
        }
    }

}
