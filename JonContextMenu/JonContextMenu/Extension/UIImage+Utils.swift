//
//  UIImage+Utils.swift
//  JonContextMenu
//
//  Created by Jonathan Martins on 11/09/2018.
//  Copyright © 2018 Surrey. All rights reserved.
//

import UIKit
import Foundation

extension UIImage{
    
    func resize(to newSize: CGFloat)-> UIImage?{
        let scale     = newSize / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newSize, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newSize, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
