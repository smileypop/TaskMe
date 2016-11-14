//
//  UIHelper.swift
//  TaskMe
//
//  Created by Matthew Laird on 11/14/16.
//  Copyright © 2016 Matthew Laird. All rights reserved.
//

import UIKit

class UIHelper {

    static var activityOverlay: UIView?
    static var activityIndicator: UIActivityIndicatorView?

    static func showActivityIndicator(in overlayParent: UIView) {

        // prevent duplicate overlays
        if (activityOverlay == nil) {

            activityOverlay = UIView(frame: overlayParent.frame)

            activityOverlay?.center = overlayParent.center
            activityOverlay?.alpha = 0
            activityOverlay?.backgroundColor = UIColor.black

            overlayParent.addSubview(activityOverlay!)
            overlayParent.bringSubview(toFront: activityOverlay!)

            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            activityOverlay?.alpha = activityOverlay!.alpha > 0 ? 0 : 0.5
            UIView.commitAnimations()

            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator?.center = activityOverlay!.center

            activityIndicator?.startAnimating()

            activityOverlay?.addSubview(activityIndicator!)
        }
    }

    static func hideActivityIndicator() {

        activityIndicator?.stopAnimating()
        activityIndicator = nil
        
        activityOverlay?.removeFromSuperview()
        activityOverlay = nil
    }
    
}
