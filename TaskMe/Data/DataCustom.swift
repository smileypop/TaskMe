//
//  DataModels.swift
//  TaskMe
//
//  Created by Matthew Laird on 11/3/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import Foundation
import RealmSwift

// THIS IS A CUSTOM CLASS FOR STORING PROJECT DATA SETTINGS - it must be customized for each project

// MARK: - Enums

//// Object Types
//enum ObjectType: String {
//    case project = "Project"
//    case task = "Task"
//
//    enum OtherStuff {
//        case one
//        case two
//    }
//}

enum CustomObject {

    // Realm Object types
    enum Entity: String {
        case project = "Project"
        case task = "Task"
    }

    // Attributes
    enum Attribute: String {
        case id
        case project_id
        case name
        case title
        case deadline
        case tasks
        case completed
        case task_sort_type
    }
}

// Path on server
enum NetworkPath {
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

    // unique key for lookup
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

    // unique key for lookup
    override static func primaryKey() -> String? {
        return "id"
    }

    override static func indexedProperties() -> [String] {
        return ["title", "deadline"]
    }
}

// MARK: - Server

class Server {

    // MARK: - Projects

    // get all projects
    static func getProjects(onSuccess: (()->Void)? = nil) {

        // GET http://localhost:8090/projects
        Network.request(with: .GET, from: [NetworkPath.server, NetworkPath.projects], onSuccess: { (json: JSON) -> Void in

            Factory.addObjects(json: json, callback: onSuccess)

        })

    }

    // get a project by id
    static func getProject(id: String, onSuccess: @escaping ()->Void) {

        // GET http://localhost:8090/projects/6
        Network.request(with: .GET, from: [NetworkPath.server, NetworkPath.projects, "/\(id)"])
    }

    // create a new project by name
    static func postProject(name: String, onSuccess: (()->Void)? = nil) {

        // POST http://localhost:8090/projects?name=HiNative
        Network.request(with: .POST, from: [NetworkPath.server, NetworkPath.projects, "?name=\(name)"], onSuccess: { (json: JSON) -> Void in

            Factory.addProject(json: json, callback: onSuccess)
            
        })
    }

    // update a project by id
    static func patchProject(id: String, name: String, onSuccess: (()->Void)? = nil) {

        // PATCH http://localhost:8090/projects/6?name=NewName
        Network.request(with: .PATCH, from: [NetworkPath.server, NetworkPath.projects, "/\(id)?name=\(name)"], onSuccess: { (json: JSON) -> Void in

            Factory.updateProject(id: id, json: json, callback: onSuccess)

        })
    }

    // delete a project by id
    static func deleteProject(id: String, onSuccess: (()->Void)? = nil) {

        // DELETE http://localhost:8090/projects/6
        Network.request(with: .DELETE, from: [NetworkPath.server, NetworkPath.projects, "/\(id)"], onSuccess: { (json: JSON) -> Void in

            Factory.deleteProject(id: id, callback: onSuccess)
            
        })
    }

    // MARK: - Tasks

    // get a task by id
    static func getTask(project_id:String, id: String) {

        // GET http://localhost:8090/projects/1/tasks/1
        Network.request(with: .GET, from: [NetworkPath.server, NetworkPath.projects, "/\(project_id)", NetworkPath.tasks, "/\(id)"])
    }

    // create a new task by title
    static func postTask(project_id:String, title: String, deadline: Int, onSuccess: (()->Void)? = nil) {

        // POST http://localhost:8090/projects/6/tasks?title=task&deadline=16284&completed=false
        Network.request(with: .POST, from: [NetworkPath.server, NetworkPath.projects, "/\(project_id)", NetworkPath.tasks, "?title=\(title)&deadline=\(deadline)"], onSuccess: { (json: JSON) -> Void in

            Factory.addTask(json: json, callback: onSuccess)

        })
    }

    // update a task title and deadline by id
    static func patchTask(project_id:String, id: String, title: String, deadline: Int, onSuccess: (()->Void)? = nil) {

        // PATCH http://localhost:8090/projects/6/tasks/2?title=changed&deadline=21196
        Network.request(with: .PATCH, from: [NetworkPath.server, NetworkPath.projects, "/\(project_id)", NetworkPath.tasks, "/\(id)?title=\(title)&deadline=\(deadline)" ], onSuccess: { (json: JSON) -> Void in

            Factory.updateTask(id: id, json: json, callback: onSuccess)
            
        })
    }

    // update a task is completed (true/false)
    static func patchTask(project_id:String, id: String, completed:Bool, onSuccess: (()->Void)? = nil) {

        // PATCH http://localhost:8090/projects/6/tasks/2?completed=false
        Network.request(with: .PATCH, from: [NetworkPath.server, NetworkPath.projects, "/\(project_id)", NetworkPath.tasks, "/\(id)?completed=\(completed)" ], onSuccess: { (json: JSON) -> Void in

            Factory.updateTask(id: id, json: json, callback: onSuccess)

        })
    }

    // delete a task by id
    static func deleteTask(project_id:String, id: String, onSuccess: (()->Void)? = nil) {

        // DELETE http://localhost:8090/projects/6/tasks/2
        Network.request(with: .DELETE, from: [NetworkPath.server, NetworkPath.projects, "/\(id)", NetworkPath.tasks, "/\(id)"], onSuccess: { (json: JSON) -> Void in

            Factory.deleteTask(id: id, callback: onSuccess)

        })
    }

}

// MARK: - Factory

class Factory {

    // MARK: - All Objects

    // Create all projects and tasks from the Server data
    static func addObjects(json:JSON, callback:(()->Void)? = nil) {

        var projects = [Project]()

            // loop through projects
            for (_,projectJson):(String, JSON) in json {
                //Do something you want

                let project = self.createProject(json: projectJson)

                projects.append(project)

                if let tasksJson:JSON = projectJson[CustomObject.Attribute.tasks.rawValue] {

                    // loop through tasks
                    for (_, taskJson):(String, JSON) in tasksJson {

                        let task = self.createTask(json: taskJson)

                        // add the task to its parent project
                        project.tasks.append(task)

                    }

                }

        }

        Storage.shared.add(projects, callback)

    }

    // MARK: - Projects

    // create a new project by JSON
    static func createProject(json:JSON) -> Project {

        let project = Project()

        project.id = json[CustomObject.Attribute.id.rawValue].string ?? "0"
        project.name = json[CustomObject.Attribute.name.rawValue].string?.removingPercentEncoding ?? ""

        return project
        
    }

    // add a new project to storage
    static func addProject(json:JSON, callback:(()->Void)? = nil) {

        let project = createProject(json: json)

        Storage.shared.add(project, callback)
        
    }

    // update a project in storage
    static func updateProject(id: String, json:JSON, callback:(()->Void)? = nil) {

        Storage.shared.update(Project.self, id, [
            CustomObject.Attribute.name.rawValue : json[CustomObject.Attribute.name.rawValue].string?.removingPercentEncoding ?? ""
            ], callback)

    }

    // delete a project from storage
    static func deleteProject(id: String, callback:(()->Void)? = nil) {

        Storage.shared.delete(Project.self, id, callback)
    }

    // MARK: - Tasks

    // create a new task by JSON
    static func createTask(json:JSON) -> Task {

        let task = Task()

        task.id = json[CustomObject.Attribute.id.rawValue].string ?? "0"
        task.project_id = json[CustomObject.Attribute.project_id.rawValue].string ?? "0"
        task.title = json[CustomObject.Attribute.title.rawValue].string?.removingPercentEncoding ?? ""
        task.completed = json[CustomObject.Attribute.completed.rawValue].bool ?? false

        if let deadline = json[CustomObject.Attribute.deadline.rawValue].int {

            task.deadline = NSDate(timeIntervalSince1970: Double(deadline))

        }
        
        return task
        
    }

    // add a new task to storage
    static func addTask(json:JSON, callback:(()->Void)? = nil) {

        let task = createTask(json: json)

        Storage.shared.append(task, Project.self, task.project_id, CustomObject.Attribute.tasks.rawValue, callback)

    }

    // update a task in storage
    static func updateTask(id: String, json:JSON, callback:(()->Void)? = nil) {

        var values = [String: Any]()

        if let title = json[CustomObject.Attribute.title.rawValue].string?.removingPercentEncoding {
            values[CustomObject.Attribute.title.rawValue] = title
        }

        if let completed = json[CustomObject.Attribute.completed.rawValue].bool {
            values[CustomObject.Attribute.completed.rawValue] = completed
        }

        if let deadline = json[CustomObject.Attribute.deadline.rawValue].int {
            values[CustomObject.Attribute.deadline.rawValue] = NSDate(timeIntervalSince1970: Double(deadline))
        }

        Storage.shared.update(Task.self, id, values, callback)
        
    }

    // delete a task in storage
    static func deleteTask(id: String, callback:(()->Void)? = nil) {

        Storage.shared.delete(Task.self, id, callback)
    }

}
