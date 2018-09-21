//
//  UIView+Utils.swift
//  Pedida de Hoje
//
//  Created by Jonathan Martins on 22/06/18.
//  Copyright © 2018 Jussi. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius  = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    var fullCircle: Bool {
        get{
            return layer.cornerRadius == 0 ? false:true
        }
        set {
            if newValue {
                layer.cornerRadius = bounds.size.width/2
            } else {
                layer.cornerRadius = 0
            }
        }
    }
    
    var borderWidth: CGFloat{
        get {
            return layer.borderWidth
        }
        set{
            layer.borderWidth = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    var borderColor: UIColor?{
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set{
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func addDropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 2
    }
}
