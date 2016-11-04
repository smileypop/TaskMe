//
//  Custom.swift
//  TaskMe
//
//  Created by Matthew Laird on 11/3/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import Foundation

// custom date formatter
extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
