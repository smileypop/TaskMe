//
//  UIHelper.swift
//  TaskMe
//
//  Created by Matthew Laird on 11/14/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit

class UIHelper {

    enum UserInteractionNotification: String {
        case enabled = "UIHelperUserInteractionEnabledNotification"
        case disabled = "UIHelperUserInteractionDisabledNotification"
    }

    // show an alert if there is a network error
    static func showNetworkErrorAlert(with action: (()->Void)?) {

        DispatchQueue.main.async {

            // create an alert
            let alertController = UIAlertController(title: "ERROR", message: "Please turn on the server and try again.", preferredStyle: UIAlertControllerStyle.alert)

            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in

                // do  action
                action?()
            }

            alertController.addAction(okAction)

            // show the alert
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                rootVC.present(alertController, animated: true)
            }
        }
    }

    // Notify the app if user interaction has changed
    static func setUserInteraction(_ userInteraction: UserInteractionNotification) {

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: userInteraction.rawValue), object: nil)
    }

}
