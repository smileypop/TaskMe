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

    static var errorActions = [()->Void]()

    static func getPath(from params:[String]) -> String {

        var url = ""

        for param in params {
            url.append(String(param))
        }

        return url
    }

    static func request(with method: HTTPMethod, from params:[String], onSuccess: ((JSON)->Void)? = nil) {

        let path = getPath(from: params)

        // We need to % encode the query params
        let url = URL(string:path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

        var request = URLRequest(url: url!)
        request.httpMethod = method.rawValue
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard error == nil else {
                print(error!)

                let alertController = UIAlertController(title: "ERROR", message: "Please turn on the server and try again.", preferredStyle: UIAlertControllerStyle.alert)

                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in

                    // try the request again
                    //self.request(with: method, from: params, onSuccess: onSuccess)

                    // execute error actions
                    for action in self.errorActions {

                        action()
                    }
                }

                alertController.addAction(okAction)

                if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                    rootVC.present(alertController, animated: true)
                }

                return
            }
            guard let data = data else {
                print("Data is empty")

                onSuccess?(JSON.null)

                return
            }

            onSuccess?(JSON(data:data))
        }
        
        task.resume()

    }

}
