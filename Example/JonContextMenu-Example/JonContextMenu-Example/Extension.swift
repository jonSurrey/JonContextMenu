//
//  Extension.swift
//  JonContextMenu-Example
//
//  Created by Jonathan Martins on 11/09/2018.
//  Copyright © 2018 Surrey. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    
    /// Takes an Hexadecimal String value and converts to UIColor
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UITableView {
    
    /// Register a Cell in the TableView given an UITableViewCell Type
    func registerCell<T:UITableViewCell>(_ cell:T.Type){
        self.register(T.self, forCellReuseIdentifier: String(describing: T.self))
    }
    
    /// Returns a UITableViewCell for a given Class Type
    func getCell<T:UITableViewCell>(_ indexPath: IndexPath, _ type:T.Type) -> T?{
        return self.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T
    }
}
