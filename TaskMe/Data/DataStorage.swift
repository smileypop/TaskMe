//
//  DataStorage.swift
//
//  Created by Matthew Laird on 11/03/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.

import Foundation
import RealmSwift

struct Storage {

    static var shared = Storage()

    // MARK: Realm

     private lazy var defaultRealm: Realm = {

        do {
            // don't save Realm between app sessions
            let realm = try Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

            print("Realm is ready")

            return realm

        } catch let error as NSError {
            // handle error
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

    }()

    mutating func objects<T: Object>(_ type: T.Type) -> Results<T>? {

        return self.defaultRealm.objects(type)
    }

    mutating func add(_ object: Object, _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "addObject").async {
            autoreleasepool {

                // Get realm and table instances for this thread
                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                realm.add(object, update: true)

                // Commit the write transaction
                // to make this data available to other threads
                try! realm.commitWrite()

                onSuccess?()
                
            }
        }
    }

    mutating func add(_ objects: [Object], _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "addObjects").async {
            autoreleasepool {

                // Get realm and table instances for this thread
                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                for object in objects {
                    realm.add(object, update: true)
                }

                // Commit the write transaction
                // to make this data available to other threads
                try! realm.commitWrite()

                onSuccess?()
                
            }
        }

    }

    mutating func update<T: Object>(_ type: T.Type, _ id: String, _ dictionary: [String: Any], _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "updateObject").async {
            autoreleasepool {

                // Get realm and table instances for this thread
                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                if let object = realm.object(ofType: type, forPrimaryKey: id){

                    for (key, value) in dictionary {

                        object.setValue(value, forKeyPath: key)
                    }
                }

                // Commit the write transaction
                // to make this data available to other threads
                try! realm.commitWrite()
                
                onSuccess?()
                
            }
        }
    }

    mutating func delete<T: Object>(_ type: T.Type, _ id: String, _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "deleteObject").async {
            autoreleasepool {

                // Get realm and table instances for this thread
                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                if let object = realm.object(ofType: type, forPrimaryKey: id){

                    realm.delete(object)
                }

                // Commit the write transaction
                // to make this data available to other threads
                try! realm.commitWrite()
                
                onSuccess?()
                
            }
        }
    }

    mutating func deleteAll(_ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "deleteAll").async {
            autoreleasepool {

                // Get realm and table instances for this thread
                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                try! realm.write {
                    realm.deleteAll()
                }

                onSuccess?()
                
            }
        }
    }

    mutating func append<T: Object, P: Object>(_ object: T, _ parentType: P.Type, _ parentId: String, _ listName: String, _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "appendObject").async {
            autoreleasepool {

                // Get realm and table instances for this thread
                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                if let parent = realm.object(ofType: parentType, forPrimaryKey: parentId){

                    if let list = parent.value(forKey: listName) as! List<T>? {
                        list.append(object)
                    }

                    // Commit the write transaction
                    // to make this data available to other threads
                    try! realm.commitWrite()
                    
                    onSuccess?()
                    
                }
            }
        }
    }

    //    mutating func writeToRealm(_ realm:Realm, action: @escaping () -> Void, onSuccess: (() -> Void)? = nil) {
    //
    //        DispatchQueue(label: "writeToRealm").async {
    //            autoreleasepool {
    //
    //                // Get realm and table instances for this thread
    //                //let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
    //
    //                realm.beginWrite()
    //
    //                // do action
    //                action()
    //
    //                // Commit the write transaction
    //                // to make this data available to other threads
    //                try! realm.commitWrite()
    //
    //                onSuccess?()
    //
    //            }
    //        }
    //
    //    }

}


