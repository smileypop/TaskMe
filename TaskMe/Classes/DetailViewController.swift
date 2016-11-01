//
//  DetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/31/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit

class DetailViewController : UIViewController {

    // MARK: - Class properties

    enum ViewMode: String {
        case add = "Add"
        case update = "Edit"
    }

    // MARK: - Instance variables

    @IBOutlet weak var titleTextField: UITextField!

    var viewMode:ViewMode!
    var targetObject: AnyObject?
    var objectType:TableViewController.ObjectType!

    lazy var objectTitle: String = { [weak self] in
        (self?.titleTextField.text!.isEmpty)! ? "My " + (self?.objectType.rawValue)!  : (self?.titleTextField.text!)!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationItem.title = self.viewMode.rawValue + " " + self.objectType.rawValue

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone(_:)))
        self.navigationItem.rightBarButtonItem = doneButton

        // do custom setup
        self.setup()

        // set the cursor to the title text
        self.titleTextField.becomeFirstResponder()
    }

    // MARK: Override for each custom subclass
    func setup() {}

    func addObject() {}

    func updateObject() {}

    // MARK: Navigation actions

    func onDone(_ sender: Any) {

        switch(self.viewMode!) {
        case .add:
            self.addObject()
        case .update:
            self.updateObject()
        }

    }

    func onCancel(_ sender: Any) {

        self.dismissSelf()
    }

    func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

}
