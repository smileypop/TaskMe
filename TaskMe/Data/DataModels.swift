//
//  DataModels.swift
//  TaskMe
//
//  Created by Matthew Laird on 11/3/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - Enums

enum ObjectType: String {
    case project = "Project"
    case task = "Task"
}

enum ObjectAttributes: String {
    case id
    case project_id
    case name
    case deadline
    case tasks
    case completed
    case task_sort_type
}

class Models {

    static var idForNewObject = [ObjectType.project.rawValue : 1,
                         ObjectType.task.rawValue : 1]

    static func getIdForNewObject(_ type:ObjectType) -> Int
    {

        if let objectId = idForNewObject[type.rawValue] {

            idForNewObject[type.rawValue]! += 1

            return objectId

        }

        return 0
    }

}

// MARK: - Classes

// Project model
class Project: Object {
    dynamic var id = 0
    dynamic var name = ""
    dynamic var task_sort_type = "name"
    let tasks = List<Task>()

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}

// Task model
class Task: Object {
    dynamic var id = 0
    dynamic var project_id = 0
    let projects = LinkingObjects(fromType: Project.self, property: "tasks")
    dynamic var name = ""
    dynamic var deadline = NSDate()
    dynamic var completed = false

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func indexedProperties() -> [String] {
        return ["name", "deadline"]
    }
}
