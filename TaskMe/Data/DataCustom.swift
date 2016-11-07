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

enum ObjectAttribute: String {
    case id
    case project_id
    case name
    case title
    case deadline
    case tasks
    case completed
    case task_sort_type
}

class ObjectPath {
    static let server = "http://localhost:8090"
    static let projects = "/projects"
    static let tasks = "/tasks"
}

// MARK: - Objects

// Project
class Project: Object {
    dynamic var id = "0"
    dynamic var name = ""
    dynamic var task_sort_type = "title"
    let tasks = List<Task>()

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}

// Task
class Task: Object {
    dynamic var id = "0"
    dynamic var project_id = "0"
    let projects = LinkingObjects(fromType: Project.self, property: "tasks")
    dynamic var title = ""
    dynamic var deadline = NSDate()
    dynamic var completed = false

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func indexedProperties() -> [String] {
        return ["title", "deadline"]
    }
}

class Server {

    // MARK: - Projects

    static func getProjects(onSuccess: (()->Void)? = nil) {

        // GET http://localhost:8090/projects
        Network.request(with: .GET, from: [ObjectPath.server, ObjectPath.projects], onSuccess: { (json: JSON) -> Void in

            Factory.addObjects(json: json, callback: onSuccess)

        })

    }

    static func getProject(id: String, onSuccess: @escaping ()->Void) {

        // GET http://localhost:8090/projects/6
        Network.request(with: .GET, from: [ObjectPath.server, ObjectPath.projects, "/\(id)"])
    }

    static func postProject(name: String, onSuccess: (()->Void)? = nil) {

        // POST http://localhost:8090/projects?name=HiNative
        Network.request(with: .POST, from: [ObjectPath.server, ObjectPath.projects, "?name=\(name)"], onSuccess: { (json: JSON) -> Void in

            Factory.addProject(json: json, callback: onSuccess)
            
        })
    }

    static func patchProject(id: String, name: String, onSuccess: (()->Void)? = nil) {

        // PATCH http://localhost:8090/projects/6?name=NewName
        Network.request(with: .PATCH, from: [ObjectPath.server, ObjectPath.projects, "/\(id)?name=\(name)"], onSuccess: { (json: JSON) -> Void in

            Factory.updateProject(id: id, json: json, callback: onSuccess)

        })
    }

    static func deleteProject(id: String, onSuccess: (()->Void)? = nil) {

        // DELETE http://localhost:8090/projects/6
        Network.request(with: .DELETE, from: [ObjectPath.server, ObjectPath.projects, "/\(id)"], onSuccess: { (json: JSON) -> Void in

            Factory.deleteProject(id: id, callback: onSuccess)
            
        })
    }

    // MARK: - Tasks

    static func getTask(project_id:String, id: String) {

        // GET http://localhost:8090/projects/1/tasks/1
        Network.request(with: .GET, from: [ObjectPath.server, ObjectPath.projects, "/\(project_id)", ObjectPath.tasks, "/\(id)"])
    }

    static func postTask(project_id:String, title: String, deadline: Int, onSuccess: (()->Void)? = nil) {

        // POST http://localhost:8090/projects/6/tasks?title=task&deadline=16284&completed=false
        Network.request(with: .POST, from: [ObjectPath.server, ObjectPath.projects, "/\(project_id)", ObjectPath.tasks, "?title=\(title)&deadline=\(deadline)"], onSuccess: { (json: JSON) -> Void in

            Factory.addTask(json: json, callback: onSuccess)

        })
    }

    static func patchTask(project_id:String, id: String, title: String, deadline: Int, onSuccess: (()->Void)? = nil) {

        // PATCH http://localhost:8090/projects/6/tasks/2?title=changed&deadline=21196
        Network.request(with: .PATCH, from: [ObjectPath.server, ObjectPath.projects, "/\(project_id)", ObjectPath.tasks, "/\(id)?title=\(title)&deadline=\(deadline)" ], onSuccess: { (json: JSON) -> Void in

            Factory.updateTask(id: id, json: json, callback: onSuccess)
            
        })
    }

    static func patchTask(project_id:String, id: String, completed:Bool, onSuccess: (()->Void)? = nil) {

        // PATCH http://localhost:8090/projects/6/tasks/2?completed=false
        Network.request(with: .PATCH, from: [ObjectPath.server, ObjectPath.projects, "/\(project_id)", ObjectPath.tasks, "/\(id)?completed=\(completed)" ], onSuccess: { (json: JSON) -> Void in

            Factory.updateTask(id: id, json: json, callback: onSuccess)

        })
    }

    static func deleteTask(project_id:String, id: String, onSuccess: (()->Void)? = nil) {

        // DELETE http://localhost:8090/projects/6/tasks/2
        Network.request(with: .DELETE, from: [ObjectPath.server, ObjectPath.projects, "/\(id)", ObjectPath.tasks, "/\(id)"], onSuccess: { (json: JSON) -> Void in

            Factory.deleteTask(id: id, callback: onSuccess)

        })
    }

    // MARK: - Errors

    static func fakeError() {

        Network.request(with: .GET, from: ["fakePath"])
    }

}

// MARK: - Models

//class Models {
//
//    static var idForNewObject = [ObjectType.project.rawValue : 1,
//                         ObjectType.task.rawValue : 1]
//
//    static func getIdForNewObject(_ type:ObjectType) -> Int
//    {
//
//        if let objectId = idForNewObject[type.rawValue] {
//
//            idForNewObject[type.rawValue]! += 1
//
//            return objectId
//
//        }
//
//        return 0
//    }
//
//}

// MARK: - Factory

class Factory {

    static func addObjects(json:JSON, callback:(()->Void)? = nil) {

        var projects = [Project]()

        //If json is .Array
        //The `index` is 0..<json.count's string value
        for (_, subJson):(String, JSON) in json {
            //Do something you want
            //print(subJson)

            // loop through projects
            for (_,projectJson):(String, JSON) in json {
                //Do something you want

                let project = self.createProject(json: projectJson)

                projects.append(project)

                if let tasksJson:JSON = projectJson[ObjectAttribute.tasks.rawValue] {

                    // loop through projects
                    for (_, taskJson):(String, JSON) in tasksJson {

                        let task = self.createTask(json: taskJson)

                        // add the task to its parent project
                        project.tasks.append(task)

                    }

                }

            }
        }

        Storage.shared.add(projects, callback)

    }

    static func updateProject(id: String, json:JSON, callback:(()->Void)? = nil) {

        Storage.shared.update(Project.self, id, [
            ObjectAttribute.name.rawValue : json[ObjectAttribute.name.rawValue].string?.removingPercentEncoding ?? ""
            ], callback)

    }

    static func addProject(json:JSON, callback:(()->Void)? = nil) {

        let project = createProject(json: json)

        Storage.shared.add(project, callback)

    }

    static func createProject(json:JSON) -> Project {

        let project = Project()

        project.id = json[ObjectAttribute.id.rawValue].string ?? "0"
        project.name = json[ObjectAttribute.name.rawValue].string?.removingPercentEncoding ?? ""

        return project

    }

    static func deleteProject(id: String, callback:(()->Void)? = nil) {

        Storage.shared.delete(Project.self, id, callback)
    }

    static func addTask(json:JSON, callback:(()->Void)? = nil) {

        let task = createTask(json: json)

        Storage.shared.append(task, Project.self, task.project_id, ObjectAttribute.tasks.rawValue, callback)

    }

    static func createTask(json:JSON) -> Task {

        let task = Task()

        task.id = json[ObjectAttribute.id.rawValue].string ?? "0"
        task.project_id = json[ObjectAttribute.project_id.rawValue].string ?? "0"
        task.title = json[ObjectAttribute.title.rawValue].string?.removingPercentEncoding ?? ""
        task.completed = json[ObjectAttribute.completed.rawValue].bool ?? false

        if let deadline = json[ObjectAttribute.deadline.rawValue].int {

            task.deadline = NSDate(timeIntervalSince1970: Double(deadline))

        }

        return task

    }

    static func updateTask(id: String, json:JSON, callback:(()->Void)? = nil) {

        var values = [String: Any]()

        if let title = json[ObjectAttribute.title.rawValue].string?.removingPercentEncoding {
            values[ObjectAttribute.title.rawValue] = title
        }

        if let completed = json[ObjectAttribute.completed.rawValue].bool {
            values[ObjectAttribute.completed.rawValue] = completed
        }

        if let deadline = json[ObjectAttribute.deadline.rawValue].int {
            values[ObjectAttribute.deadline.rawValue] = NSDate(timeIntervalSince1970: Double(deadline))
        }

        Storage.shared.update(Task.self, id, values, callback)
        
    }

    static func deleteTask(id: String, callback:(()->Void)? = nil) {

        Storage.shared.delete(Task.self, id, callback)
    }

}
