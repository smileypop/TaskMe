//
//  ProjectDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/28/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit

class ProjectDetailViewController : DetailViewController {

    override func setup() {

        if let object:Project = self.targetObject as? Project {
                self.titleTextField.text = object.title
        }

    }

    // MARK: Objects

    override func addObject() {

        if let object:Project = Storage.shared.createEntity(entityName: objectType.rawValue) as? Project {

            setValues(for: object)
        }

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
        object.title = self.objectTitle

        Storage.shared.save()
        
    }
    
}
