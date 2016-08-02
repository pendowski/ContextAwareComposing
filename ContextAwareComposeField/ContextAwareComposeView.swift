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
    func composeView(composeView: ContextAwareComposeView, pressedSaveButton: UIButton)
    
    func composeView(composeView: ContextAwareComposeView, tappedOnSavedMessage savedMessage: String)

    func composeView(composeView: ContextAwareComposeView, adjustForSavedMessagesOfHeight: CGFloat)
    func viewForStoringSavesMessage(composeView: ContextAwareComposeView, savedMessage: String) -> UIView
}

private struct MessageBubble {
    let view: UIView
    let message: String
}

private let kAnimationDuration = 0.3

@IBDesignable
public class ContextAwareComposeView: UIView {

    private var messageBubbles: [MessageBubble] = []
    private var messageContainerLeft: NSLayoutConstraint!
    public private(set) var sendButton: UIButton!
    public private(set) var saveMessageButton: UIButton!
    public private(set) var messageContainer: ContextAwareFieldContainer!
    
    public var messageBubbleSize = CGSize(width: 44, height: 44) {
        didSet {
            self.realignMessageBubbles(true)
        }
    }
    @IBOutlet public weak var delegate: ContextAwareComposeViewDelegate?
    
    override public var frame: CGRect {
        didSet {
            
        }
    }
    
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
        self.saveMessageButton.addTarget(self, action: #selector(self.saveButtonPressed(_:)), forControlEvents: .TouchUpInside)
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
        
        UIView.animateWithDuration(kAnimationDuration, options: [ .AllowAnimatedContent, .BeginFromCurrentState ]) {
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
    
    @objc private func saveButtonPressed(sender: UIButton) {
        guard let message = self.messageContainer.messageContainer?.text,
            view = self.delegate?.viewForStoringSavesMessage(self, savedMessage: message),
            window = self.window,
            composeView = self.messageContainer.messageComposeView
            else {
                return
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.messageBubbleTapped(_:))))
        
        self.delegate?.composeView(self, adjustForSavedMessagesOfHeight: self.messageBubbleSize.height)
        
        window.addSubview(view)
        view.frame = self.messageContainer.convertRect(composeView.frame, toView: nil)
        
        
        let frame = self.convertRect(self.bounds, toView: nil)
        UIView.animateWithDuration(kAnimationDuration, options: [ .AllowAnimatedContent, .BeginFromCurrentState ]) {
            view.frame = CGRect(x: frame.origin.x + CGFloat(self.messageBubbles.count) * self.messageBubbleSize.width,
                                y: frame.origin.y - self.messageBubbleSize.height,
                                width: self.messageBubbleSize.width,
                                height: self.messageBubbleSize.height)
        }
        
        self.messageBubbles.append(MessageBubble(view: view, message: message))
        
        self.delegate?.composeView(self, pressedSaveButton: self.saveMessageButton)
    }
    
    @objc private func messageBubbleTapped(sender: UITapGestureRecognizer) {
        guard let index = self.messageBubbles.indexOf({ $0.view == sender.view }),
            composeView = self.messageContainer.messageComposeView else {
            sender.view?.removeFromSuperview()
            return
        }
        
        let bubble = self.messageBubbles[index]
        
        UIView.animateWithDuration(kAnimationDuration, options: [ .AllowAnimatedContent, .BeginFromCurrentState ], animations: {
            bubble.view.frame = self.messageContainer.convertRect(composeView.frame, toView: nil)
            }) { _ in
                self.delegate?.composeView(self, tappedOnSavedMessage: bubble.message)

                bubble.view.removeFromSuperview()
                self.messageBubbles.removeAtIndex(index)
                
                if self.messageBubbles.isEmpty {
                    self.delegate?.composeView(self, adjustForSavedMessagesOfHeight: 0)
                }
                
                self.realignMessageBubbles(true)
        }
        
    }
    
    // MARK: - Private
    
    private func realignMessageBubbles(animated: Bool) {
        let frame = self.convertRect(self.bounds, toView: nil)
        
        var index = 0
        self.messageBubbles.forEach({ bubble in
            UIView.animateWithDuration(animated ? kAnimationDuration : 0,
                delay: animated ? Double(index) * kAnimationDuration / 3 : 0,
                options: [ .AllowAnimatedContent, .BeginFromCurrentState ],
                animations: {
                    bubble.view.frame = CGRect(x: frame.origin.x + CGFloat(index) * self.messageBubbleSize.width,
                        y: frame.origin.y - self.messageBubbleSize.height,
                        width: self.messageBubbleSize.width,
                        height: self.messageBubbleSize.height)
                }, completion: nil)
            index += 1
        })
    }
}
