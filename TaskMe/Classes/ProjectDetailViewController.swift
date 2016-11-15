//
//  ProjectDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/28/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectDetailViewController : TMDetailViewController, TMDetailViewDelegate {

    // MARK: - TMDetailViewDelegate protocol

    func setup() {

        // Show project name
        if let object = self.targetObject as? Project {
            self.nameTextField.text = object.name
        }

    }

    override func cleanup() {

        super.cleanup()
        
        // add custom code
    }

    func addObject() {

        // Server - add a new project
        Server.postProject(name: self.objectName, onSuccess: dismissSelf)
    }

    func updateObject() {

        // Server - update project
        if let object = self.targetObject as? Project {

            Server.patchProject(id: object.id, name: self.objectName, onSuccess:self.dismissSelf)
        }

    }
    
}
