//
//  ProjectDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/28/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit

class ProjectDetailViewController : UIViewController {

    enum Mode: String {
        case Edit = "Edit Project"
        case Add = "Add Project"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doEdit(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    func setMode(_ mode:Mode, _ callback: () -> Void) {

        self.navigationItem.title = mode.rawValue
    }

    func cancelEdit(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }

    func doEdit(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
    
}
