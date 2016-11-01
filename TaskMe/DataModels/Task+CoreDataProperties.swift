//
//  Task+CoreDataProperties.swift
//  TaskMe
//
//  Created by Matthew Laird on 11/1/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task");
    }

    @NSManaged public var deadline: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var isComplete: Bool = false

}
