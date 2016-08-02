//
//  InsetTextField.swift
//  ContextComposeField
//
//  Created by Jarosław Pendowski on 02/08/16.
//  Copyright © 2016 Jarosław Pendowski. All rights reserved.
//

import UIKit

@IBDesignable
class InsetTextField: UITextField {
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
}
