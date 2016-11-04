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

    private var realm: Realm = {

        do {
            // don't save Realm between app sessions
            let realm = try Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))

            return realm

        } catch let error as NSError {
            // handle error
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

    }()

    func objects<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }

    mutating func add(_ object: Object, _ dictionary: [String: Any]) {

        try! realm.write {

            for (key, value) in dictionary {

                object.setValue(value, forKeyPath: key)
            }

            realm.add(object, update: true)
        }
    }

    mutating func append<T>(_ object:T, _ list: List<T>) {

        try! realm.write {
            list.append(object)
        }
    }

    mutating func delete(_ object: Object) {
        try! realm.write {
            realm.delete(object)
        }
    }

}


