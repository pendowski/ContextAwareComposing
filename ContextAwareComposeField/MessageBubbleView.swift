//
//  MessageBubbleView.swift
//  ContextComposeField
//
//  Created by Jarosław Pendowski on 02/08/16.
//  Copyright © 2016 Jarosław Pendowski. All rights reserved.
//

import UIKit

enum PanningState {
    case Began
    case Changed
    case Ended
}

protocol MessageBubbleViewDelegate: class {
    func messageBubbleViewTapped(view: MessageBubbleView)
    func messageBubbleViewPanned(view: MessageBubbleView, state: PanningState, delta: CGPoint)
}

class MessageBubbleView: UIView {
    
    weak var delegate: MessageBubbleViewDelegate?
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    convenience init(frame: CGRect, view: UIView, delegate: MessageBubbleViewDelegate) {
        self.init(frame: frame)
        
        view.frame = self.bounds
        view.autoresizingMask = [ .FlexibleWidth, .FlexibleHeight ]
        self.addSubview(view)
        
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    private func commonInit() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:))))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.viewPanned(_:))))
    }
    
    // MARK: - Actions
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        self.delegate?.messageBubbleViewTapped(self)
    }
    
    @objc func viewPanned(sender: UIPanGestureRecognizer) {
        let delta = sender.translationInView(self)
        
        var state: PanningState = .Ended
        if sender.state == .Began {
            state = .Began
        } else if sender.state == .Changed {
            state = .Changed
        }
        
        self.delegate?.messageBubbleViewPanned(self, state: state, delta: delta)
        
        sender.setTranslation(CGPointZero, inView: self)
    }
}
