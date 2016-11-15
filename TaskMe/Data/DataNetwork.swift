//
//  DataNetwork.swift
//  TaskMe
//
//  Created by Matthew Laird on 11/4/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import Foundation
import UIKit

class Network {

    enum ResponseNotification: String {
        case error = "NetworkResponseError"
    }

    enum HTTPMethod:String {
        case GET, POST, PATCH, DELETE

    }

    // Create a URL path
    static func getPath(from params:[String]) -> String {

        var url = ""

        // add each param to the path
        for param in params {
            url.append(String(param))
        }

        return url
    }

    // Try to make a server request
    static func request(with method: HTTPMethod, from params:[String], onSuccess: ((JSON)->Void)? = nil) {

        // create a path
        let path = getPath(from: params)

        // We need to % encode the query params
        let url = URL(string:path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

        var request = URLRequest(url: url!)
        request.httpMethod = method.rawValue
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard error == nil else {

                // ERROR
                print(error!)

                UIHelper.showNetworkErrorAlert( with: {

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: ResponseNotification.error.rawValue), object: nil)
                })

                return
            }
            guard let data = data else {

                // NO DATA
                print("Data is empty")

                // call the success method with null
                onSuccess?(JSON.null)

                return
            }

            // call the success method with JSON data
            onSuccess?(JSON(data:data))
        }
        
        task.resume()

    }

}
