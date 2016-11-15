//
//  DetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/31/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - TMDetailViewDelegate

protocol TMDetailViewDelegate {

    func setup()

    func cleanup()

    func addObject()

    func updateObject()

}

// MARK: - TMDetailViewController

class TMDetailViewController : UIViewController, UITextFieldDelegate {

    // MARK: - Enums

    enum ViewMode: String {
        case add = "Add"
        case update = "Edit"
    }

    // MARK: - Properties

    @IBOutlet weak var nameTextField: UITextField!

    var delegate:TMDetailViewDelegate!
    var targetObject: Object?
    var viewMode:ViewMode!
    var objectType:CustomObject.Entity!
    private var networkErrorObserver: NSObjectProtocol!         // network error listener

    lazy var objectName: String = { [weak self] in
        (self?.nameTextField.text!.isEmpty)! ? "My " + (self?.objectType.rawValue)!  : (self?.nameTextField.text!)!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set the delegate
        self.delegate = self as! TMDetailViewDelegate

        // do custom setup
        self.delegate.setup()

        // set the cursor to the title text
        self.nameTextField.becomeFirstResponder()

        // listen for taps
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))

        // setup the navigation bar
        self.navigationItem.title = self.viewMode.rawValue + " " + self.objectType.rawValue
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton

        // add error listener
        networkErrorObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Network.ResponseNotification.error.rawValue),
                                                                      object: nil,
                                                                      queue: OperationQueue.main) { [weak self] notification in
                                                                        self?.dismissSelf()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)

        // cleanup delegate
        self.delegate.cleanup()

        // clear references
        self.delegate = nil
        self.targetObject = nil
    }

    // show the Done button after the view is ready
    func showDoneButton() {

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    // hide the keyboard if user taps the view
    func dismissKeyboard(_ sender: Any) {
        self.nameTextField.resignFirstResponder()

    }

    // hide the keyboard if user presses Enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: Navigation actions

    // User pressed Done button
    func onDone(_ sender: Any) {

        switch(self.viewMode!) {
        case .add:
            self.delegate.addObject()
        case .update:
            self.delegate.updateObject()
        }

    }

    // User pressed Cancel button
    func onCancel(_ sender: Any) {

        self.dismissSelf()
    }

    // View will close
    func dismissSelf() {
        
        self.dismiss(animated: true, completion: {

            UIHelper.setUserInteraction(.enabled)
        })
    }

    func cleanup() {

        // clear listeners
        if self.networkErrorObserver != nil {
            NotificationCenter.default.removeObserver(networkErrorObserver)
            self.networkErrorObserver = nil
        }

    }

}
