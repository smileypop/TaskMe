//
//  TaskDetailViewController.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/26/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var completedSwitch: UISwitch!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let textField = self.titleTextField {
                textField.text = detail.title!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Task? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

}

