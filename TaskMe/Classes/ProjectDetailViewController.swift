//
//  ProjectDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/28/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectDetailViewController : DetailViewController, TMDetailView {

    // MARK: - TMDetailView protocol

    func setup() {

        if let object:Project = self.targetObject as? Project {
            self.nameTextField.text = object.name
        }

    }

    func addObject() {

        Server.postProject(name: self.objectName, onSuccess: dismissSelf)
    }

    func updateObject() {

        if let object = self.targetObject as? Project {

            Server.patchProject(id: object.id, name: self.objectName, onSuccess:self.dismissSelf)
        }

    }
    
}
