//
//  TaskTableViewCell.swift
//  TaskMe
//
//  Created by Matthew Laird on 10/27/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var completedSwitch: UISwitch!

    var task:Task? = nil

    @IBAction func onCompletedSwitchToggle(sender: UISwitch)
    {
        if let object = task {

            Server.patchTask(project_id: object.project_id, id: object.id, completed: sender.isOn)
        }
    }

    deinit
    {
        task = nil
    }
}
