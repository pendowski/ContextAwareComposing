//
//  ContextAwareComposeView.swift
//  ContextComposeField
//
//  Created by Jarosław Pendowski on 01/08/16.
//  Copyright © 2016 Jarosław Pendowski. All rights reserved.
//

import UIKit

@objc public protocol ContextAwareComposeViewDelegate: class {
    func composeView(composeView: ContextAwareComposeView, pressedSendButton: UIButton)
    func viewForSavedMessages(composeView: ContextAwareComposeView) -> UIView
}

@IBDesignable
public class ContextAwareComposeView: UIView {

    private var messageContainerLeft: NSLayoutConstraint!
    public private(set) var sendButton: UIButton!
    public private(set) var saveMessageButton: UIButton!
    public private(set) var messageContainer: ContextAwareFieldContainer!
    
    @IBOutlet public weak var delegate: ContextAwareComposeViewDelegate?
    
    public var saveButtonVisible: Bool {
        get {
            return self.saveMessageButton.alpha > 0
        }
        set {
            self.saveMessageButton.alpha = newValue ? 1 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupSubviews()
    }
    
    private func setupSubviews() {
        
        self.saveMessageButton = UIButton(type: .ContactAdd)
        self.saveMessageButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.addSubview(self.saveMessageButton)
        self.saveMessageButton.translatesAutoresizingMaskIntoConstraints = false
        self.saveMessageButton.alpha = 0
        self.saveMessageButton.transform = CGAffineTransformMakeTranslation(-1.0 * CGRectGetWidth(self.saveMessageButton.bounds), 0)
        
        self.messageContainer = ContextAwareFieldContainer()
        self.messageContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.messageContainer)
        
        self.sendButton = UIButton(type: .System)
        self.sendButton.setTitle("Send", forState: .Normal)
        self.sendButton.sizeToFit()
        self.sendButton.addTarget(self, action: #selector(self.sendButtonPressed(_:)), forControlEvents: .TouchUpInside)
        self.sendButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.sendButton)
        
        let views = [ "send" : self.sendButton, "message" : self.messageContainer, "save" : self.saveMessageButton ]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[send]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[message]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[save]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[message]-[send]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[save]", options: [], metrics: nil, views: views))
        
        self.messageContainerLeft = self.messageContainer.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 0)
        self.messageContainerLeft.active = true
    }
    
    // MARK: - Animated properties
    
    public func setSaveButtonVisible(visible: Bool, animated: Bool) {
        guard animated else {
            self.saveButtonVisible = visible
            return
        }

        let width = CGRectGetWidth(self.saveMessageButton.bounds)
        let translation: CGFloat = visible ? 0.0 : -1.0
        
        UIView.animateWithDuration(0.3) {
            self.messageContainerLeft.constant = visible ? width : 0
            self.layoutIfNeeded()
            self.saveMessageButton.transform = CGAffineTransformMakeTranslation(translation * width, 0)
            self.saveMessageButton.alpha = visible ? 1 : 0
        }
        
    }

    // MARK: - Actions
    
    @objc private func sendButtonPressed(sender: UIButton) {
        self.delegate?.composeView(self, pressedSendButton: sender)
    }
}
