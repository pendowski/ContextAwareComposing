//
//  BubbleView.swift
//  ContextComposeField
//
//  Created by Jarosław Pendowski on 01/08/16.
//  Copyright © 2016 Jarosław Pendowski. All rights reserved.
//

import UIKit

enum BubbleViewDirection: Int {
    case None = 0
    case Left = 1
    case Right = 2
}

@IBDesignable class BubbleView: UIView {
    
    @IBInspectable var bubbleDirectionIB: Int {
        get {
            return self.bubbleDirection.rawValue
        }
        set {
            self.bubbleDirection = BubbleViewDirection(rawValue: newValue) ?? .None
        }
    }

    var bubbleDirection: BubbleViewDirection = .None {
        didSet {
            self.updateMask()
        }
    }
    
    @IBInspectable var roundRadius: CGFloat = 4 {
        didSet {
            self.updateMask()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateMask()
    }
    
    // MARK: - Private
    
    func updateMask() {
        var corners: UIRectCorner = [ .AllCorners ]
        
        switch self.bubbleDirection {
        case .None:
            corners = [ .AllCorners ]
        case .Left:
            corners = [ .BottomRight, .TopLeft, .TopRight ]
        case .Right:
            corners = [ .BottomLeft, .TopLeft, .TopRight ]
        }
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: self.roundRadius, height: self.roundRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.CGPath
        
        self.layer.mask = maskLayer
    }

}
