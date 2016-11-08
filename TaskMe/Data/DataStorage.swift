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


    // get all Objects of Type
    mutating func objects<T: Object>(_ type: T.Type) -> Results<T>? {

        return self.defaultRealm.objects(type)
    }

    // add an Object
    mutating func add(_ object: Object, _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "addObject").async {
            autoreleasepool {

                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                realm.add(object, update: true)

                try! realm.commitWrite()

                onSuccess?()
                
            }
        }
    }

    // add an array of Objects
    mutating func add(_ objects: [Object], _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "addObjects").async {
            autoreleasepool {

                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                for object in objects {
                    realm.add(object, update: true)
                }

                try! realm.commitWrite()

                onSuccess?()
                
            }
        }

    }

    // update an Object
    mutating func update<T: Object>(_ type: T.Type, _ id: String, _ dictionary: [String: Any], _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "updateObject").async {
            autoreleasepool {

                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                if let object = realm.object(ofType: type, forPrimaryKey: id){

                    for (key, value) in dictionary {

                        object.setValue(value, forKeyPath: key)
                    }
                }

                try! realm.commitWrite()
                
                onSuccess?()
                
            }
        }
    }

    // delete an Object
    mutating func delete<T: Object>(_ type: T.Type, _ id: String, _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "deleteObject").async {
            autoreleasepool {

                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                if let object = realm.object(ofType: type, forPrimaryKey: id){

                    realm.delete(object)
                }

                try! realm.commitWrite()
                
                onSuccess?()
                
            }
        }
    }

    // delete all Objects
    mutating func deleteAll(_ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "deleteAll").async {
            autoreleasepool {

                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                try! realm.write {
                    realm.deleteAll()
                }

                onSuccess?()
                
            }
        }
    }

    // add an Object to a List
    mutating func append<T: Object, P: Object>(_ object: T, _ parentType: P.Type, _ parentId: String, _ listName: String, _ onSuccess: (() -> Void)? = nil) {

        DispatchQueue(label: "appendObject").async {
            autoreleasepool {

                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

                realm.beginWrite()

                if let parent = realm.object(ofType: parentType, forPrimaryKey: parentId){

                    if let list = parent.value(forKey: listName) as! List<T>? {
                        list.append(object)
                    }

                    try! realm.commitWrite()
                    
                    onSuccess?()
                    
                }
            }
        }
    }

}


