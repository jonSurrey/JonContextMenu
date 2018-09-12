//
//  JonContextMenuView.swift
//  JonContextMenu
//
//  Created by Jonathan Martins on 10/09/2018.
//  Copyright © 2018 Surrey. All rights reserved.
//

import UIKit
import Foundation
import UIKit.UIGestureRecognizerSubclass

public protocol JonContextMenuDelegate {
    func menuOpened()
    func menuClosed()
    func menuItemWasSelected(_ item:JonItem, atIndex index:Int)
    func menuItemWasActivated(_ item:JonItem, atIndex index:Int)
    func menuItemWasDeactivated()
}

open class JonContextMenu{
    
    /// The items to be displayed
    var items:[JonItem] = []
    
    /// The delegate to notify the JonContextMenu host when an item is selected
    var delegate:JonContextMenuDelegate?
    
    /// The Background's alpha of the view
    var backgroundAlpha:CGFloat = 0.9
    
    /// The Background's colour of the view
    var backgroundColor:UIColor = .white
    
    /// The items' buttons default colour
    var buttonsDefaultColor:UIColor = .white
    
    /// The items' icons default colour
    var iconsDefaultColor:UIColor?
    
    /// The items' buttons active colour
    var buttonsActiveColor:UIColor = UIColor.init(hexString: "#9a0007") //Red
    
    /// The items' icons active colour
    var iconsActiveColor:UIColor?
    
    /// The size of the title of the menu items
    var itemsTitleSize:CGFloat = 64
    
    /// The colour of the title of the menu items
    var itemsTitleColor:UIColor = .darkGray
    
    /// The colour of the touch location view
    var touchPointColor:UIColor = .darkGray
    
    public init(){
        
    }
    
    /// Builds the JonContextMenu
    open func build()->Builder{
        return Builder(self)
    }
    
    /// Sets the items for the JonContextMenu
    open func setItems(_ items: [JonItem])->JonContextMenu{
        self.items = items
        return self
    }
    
    /// Sets the delegate for the JonContextMenu
    open func setDelegate(_ delegate: JonContextMenuDelegate?)->JonContextMenu{
        self.delegate = delegate
        return self
    }
    
    /// Sets the background of the JonContextMenu
    open func setBackgroundColorTo(_ backgroundColor: UIColor, withAlpha alpha:CGFloat = 0.9)->JonContextMenu{
        self.backgroundAlpha = alpha
        self.backgroundColor = backgroundColor
        return self
    }

    /// Sets the buttons and icons default colour of the JonContextMenu
    open func setItemsDefaultColorTo(_ buttonsColor: UIColor? = nil, andIconsTo iconsColor:UIColor? = nil)->JonContextMenu{
        self.iconsDefaultColor   = iconsColor
        self.buttonsDefaultColor = buttonsColor ?? .white
        return self
    }

    /// Sets the buttons and icons active colour of the JonContextMenu
    open func setItemsActiveColorTo(_ buttonsColor: UIColor? = nil, andIconsTo iconsColor:UIColor? = nil)->JonContextMenu{
        self.iconsActiveColor   = iconsColor
        self.buttonsActiveColor = buttonsColor ?? UIColor.init(hexString: "#9a0007")
        return self
    }
    
    /// Sets the colour of the JonContextMenu items title
    open func setItemsTitleColorTo(_ color: UIColor)->JonContextMenu{
        self.itemsTitleColor = color
        return self
    }
    
    /// Sets the size of the JonContextMenu items title
    open func setItemsTitleSizeTo(_ size: CGFloat)->JonContextMenu{
        self.itemsTitleSize = size
        return self
    }
    
    /// Sets the colour of the JonContextMenu touch point
    open func setTouchPointColorTo(_ color: UIColor)->JonContextMenu{
        self.touchPointColor = color
        return self
    }
    
    open class Builder:UILongPressGestureRecognizer{
        
        /// The wrapper for the JonContextMenu
        private var window:UIWindow!
        
        /// The selected menu item
        private var currentItem:JonItem?
        
        /// The JonContextMenu view
        private var contextMenuView:JonContextMenuView!
        
        /// The properties configuration to add to the JonContextMenu view
        private var properties:JonContextMenu!
        
        /// Indicates if there is a menu item active
        private var isItemActive = false
        
        init(_ properties:JonContextMenu){
            super.init(target: nil, action: nil)
            guard let window = UIApplication.shared.keyWindow else{
                fatalError("No access to UIApplication Window")
            }
            self.window     = window
            self.properties = properties
            addTarget(self, action: #selector(setupTouchAction))
        }
        
        /// Handle the touch events on the view
        @objc private func setupTouchAction(_ sender:UILongPressGestureRecognizer){
            let location = sender.location(in: window)
            switch sender.state {
                case .began:
                    longPressBegan(on: location)
                case .changed:
                    longPressMoved(to: location)
                case .ended:
                    longPressEnded()
                case .cancelled:
                    longPressCancelled()
                default:
                    break
            }
        }
        
        /// Trigger the events for when the touch begins
        private func longPressBegan(on location:CGPoint) {
            showMenu(on: location)
        }
        
        // Triggers the events for when the touch ends
        private func longPressEnded() {
            if let selectedItem = currentItem, let index = properties.items.index(of: selectedItem){
                properties.delegate?.menuItemWasSelected(selectedItem, atIndex: index)
            }
            dismissMenu()
        }
        
        // Triggers the events for when the touch is cancelled
        private func longPressCancelled() {
            dismissMenu()
        }
        
        // Triggers the events for when the touch moves
        private func longPressMoved(to location:CGPoint) {
            if let current = currentItem, current.frame.contains(location){
                if !isItemActive{
                    activate(current)
                    if let index = properties.items.index(of: current){
                        properties.delegate?.menuItemWasActivated(current, atIndex: index)
                    }
                }
            }
            else{
                if isItemActive{
                    deactivate(currentItem)
                    contextMenuView.hideLabel()
                    
                    currentItem = nil
                    properties.delegate?.menuItemWasDeactivated()
                }
                for action in properties.items{
                    if action.frame.contains(location){
                        currentItem = action
                        break
                    }
                }
            }
        }
        
        /// Creates the JonContextMenu view and adds to the Window
        private func showMenu(on location:CGPoint){
            contextMenuView = JonContextMenuView(properties, touchPoint: location)
            window.addSubview(contextMenuView)
            properties.delegate?.menuOpened()
        }
        
        /// Removes the JonContextMenu view from the Window
        private func dismissMenu(){
            contextMenuView.removeFromSuperview()
            properties.delegate?.menuClosed()
        }
        
        /// Activates the selected menu item
        private func activate(_ item:JonItem){
            isItemActive = true
            item.button.tintColor       = properties.iconsActiveColor
            item.button.backgroundColor = properties.buttonsActiveColor
            
            contextMenuView.showTitle(item.title)
            UIView.animate(withDuration: 0.2, animations: {
                item.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
        }
        
        /// Deactivate the selected menu item
        private func deactivate(_ item:JonItem?){
            guard let item = item else {
                return
            }
            
            isItemActive = false
            item.button.tintColor       = properties.iconsDefaultColor
            item.button.backgroundColor = properties.buttonsDefaultColor
            
            UIView.animate(withDuration: 0.2, animations: {
                item.transform = CGAffineTransform.identity
            })
        }
    }
}
