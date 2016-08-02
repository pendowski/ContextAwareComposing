//
//  UIView+Extended.swift
//  ContextComposeField
//
//  Created by Jarosław Pendowski on 02/08/16.
//  Copyright © 2016 Jarosław Pendowski. All rights reserved.
//

import UIKit

extension UIView {
    class func animateWithDuration(duration: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void) {
        self.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
    }
    
    class func animateWithDuration(duration: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) {
        self.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: completion)
    }
}