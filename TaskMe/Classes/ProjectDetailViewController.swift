//
//  ProjectDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/28/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectDetailViewController : DetailViewController {

    override func setup() {

        if let object:Project = self.targetObject as? Project {
                self.nameTextField.text = object.name
        }

    }

    // MARK: Objects

    override func addObject() {

        let object = Project()

        object.id = Models.getIdForNewObject(self.objectType)

        setValues(for: object)

        dismissSelf()
    }

    override func updateObject() {

        if let object = self.targetObject as? Project {

            setValues(for: object)
        }

        dismissSelf()
    }

    func setValues(for object: Project)
    {


        Storage.shared.add(object, [
            "name" : self.objectName
            ])
        
    }
    
}
