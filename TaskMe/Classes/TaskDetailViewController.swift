//
//  TaskDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/26/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class TaskDetailViewController: TMDetailViewController, TMDetailViewDelegate {

    // MARK: - Custom properties

    @IBOutlet weak var deadlineDatePicker: UIDatePicker!

    var project:Project!

    // MARK: - Custom methods

    deinit {
        project = nil
    }

    // MARK: - TMDetailView protocol

    func setup() {

        // EDIT the task
        if let object = self.targetObject as? Task {

            self.nameTextField.text = object.title

            self.deadlineDatePicker.date = object.deadline as Date

        } else {

            // ADD a new task

            // set the minimum date to today
            self.deadlineDatePicker.minimumDate = Date()
        }

    }

    func addObject() {

        // store the time as an Int
        let deadline = Int(floor(self.deadlineDatePicker.date.timeIntervalSince1970))

        // Server - add task
        Server.postTask(project_id: self.project.id, title: self.objectName, deadline: deadline, onSuccess: dismissSelf)
    }

    func updateObject() {

        if let object = self.targetObject as? Task {

            // store the time as an Int
            let deadline = Int(floor(self.deadlineDatePicker.date.timeIntervalSince1970))

            // Server update task
            Server.patchTask(project_id: object.project_id, id: object.id, title: self.objectName, deadline: deadline, onSuccess: dismissSelf)
        }
    }
    
}
