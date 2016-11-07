//
//  DetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/31/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

protocol TMDetailView {

    func setup()

    func addObject()

    func updateObject()
}

class DetailViewController : UIViewController, UITextFieldDelegate {

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
    var detailView:TMDetailView!

    lazy var objectName: String = { [weak self] in
        (self?.nameTextField.text!.isEmpty)! ? "My " + (self?.objectType.rawValue)!  : (self?.nameTextField.text!)!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationItem.title = self.viewMode.rawValue + " " + self.objectType.rawValue

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton

        self.detailView = self as! TMDetailView

        // do custom setup
        self.detailView.setup()

        // set the cursor to the title text
        self.nameTextField.becomeFirstResponder()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))

    }

    func showDoneButton() {

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    func dismissKeyboard(_ sender: Any) {
        self.nameTextField.resignFirstResponder()

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    deinit {
        targetObject = nil
    }

    // MARK: Navigation actions

    func onDone(_ sender: Any) {

        switch(self.viewMode!) {
        case .add:
            self.detailView.addObject()
        case .update:
            self.detailView.updateObject()
        }

    }

    func onCancel(_ sender: Any) {

        self.dismissSelf()
    }

    func dismissSelf() {
        self.dismiss(animated: true, completion: {

            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

            // hide menu for iPad
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                appDelegate.splitViewController.preferredDisplayMode = .allVisible
                
            }

        })
    }

}
