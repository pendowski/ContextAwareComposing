//
//  ContextAwareFieldContainer.swift
//  ContextComposeField
//
//  Created by Jarosław Pendowski on 01/08/16.
//  Copyright © 2016 Jarosław Pendowski. All rights reserved.
//

import UIKit

public protocol MessageContainer {
    var text: String? { get }
}

public class ContextAwareFieldContainer: UIView {
    
    public var messageContainer: MessageContainer? {
        get {
            return self.messageComposeView as? MessageContainer
        }
    }
    
    public private(set) var messageComposeView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let newValue = messageComposeView {
                newValue.frame = self.bounds
                self.addSubview(newValue)
                
                newValue.translatesAutoresizingMaskIntoConstraints = false
                newValue.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
                newValue.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
                newValue.heightAnchor.constraintEqualToAnchor(self.heightAnchor, multiplier: 1).active = true
                newValue.widthAnchor.constraintEqualToAnchor(self.widthAnchor, multiplier: 1).active = true
            }
        }
    }
    
    public func setMessageComposeView<View: UIView where View:MessageContainer>(view: View) {
        self.messageComposeView = view
    }
}
