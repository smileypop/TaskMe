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

    enum HTTPMethod:String {
        case GET, POST, PATCH, DELETE

    }

    // Keep a lister of Error listeners
    static var errorActions = [()->Void]()

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

                // create an alert
                let alertController = UIAlertController(title: "ERROR", message: "Please turn on the server and try again.", preferredStyle: UIAlertControllerStyle.alert)

                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in

                    // execute error actions
                    for action in self.errorActions {

                        action()
                    }
                }

                alertController.addAction(okAction)

                // show the alert
                if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                    rootVC.present(alertController, animated: true)
                }

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
