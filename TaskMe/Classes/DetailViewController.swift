//
//  DetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/31/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

class DetailViewController : UIViewController {

    // MARK: - Class properties

    enum ViewMode: String {
        case add = "Add"
        case update = "Edit"
    }

    // MARK: - Instance variables

    @IBOutlet weak var nameTextField: UITextField!

    var viewMode:ViewMode!
    var objectType:ObjectType!
    var targetObject: Object?

    lazy var objectName: String = { [weak self] in
        (self?.nameTextField.text!.isEmpty)! ? "My " + (self?.objectType.rawValue)!  : (self?.nameTextField.text!)!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationItem.title = self.viewMode.rawValue + " " + self.objectType.rawValue

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton

        // do custom setup
        self.setup()

        // set the cursor to the title text
        self.nameTextField.becomeFirstResponder()
    }

    func showDoneButton() {

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    deinit {
        targetObject = nil
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
