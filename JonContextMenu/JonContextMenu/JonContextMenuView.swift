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
    func menuItemWasActivated(_ item:JonAction)
    func menuItemWasSelected(_ item:JonAction)
    func menuItemWasDeactivated()
}

open class JonContextMenu: UIGestureRecognizer{
    
    private var window:UIWindow!
    private var contextMenuView:JonContextMenuView!
    private var _delegate:JonContextMenuDelegate?
    
    private var options:[JonAction] = []
    func set(options: [JonAction]){
        self.options = options
    }
    
    private var backgroundColor:UIColor = .white
    func setBackgroundColorTo(color: UIColor){
        self.backgroundColor = color
    }
    
    private var backgroundAlpha:CGFloat = 0.9
    func setBackgroundAlphaTo(_ alpha:CGFloat){
        self.backgroundAlpha = alpha
    }
    
    private var buttonDefaultColor:UIColor = .white
    private var iconDefaultColor:UIColor   = UIColor.init(hexString: "#424242")//Drak Grey
    func setButtonColor(to color: UIColor, andIconTo iconColor:UIColor){
        self.buttonDefaultColor = color
        self.iconDefaultColor   = iconColor
    }
    
    private var buttonActiveColor:UIColor = UIColor.init(hexString: "#9a0007") //Red
    private var iconActiveColor:UIColor   = .white
    func setButtonActiveColor(to color: UIColor, andIconTo iconColor:UIColor){
        self.buttonActiveColor = color
        self.iconActiveColor   = iconColor
    }
    
    private var optionsTitleColor:UIColor = UIColor.init(hexString: "#424242") //Drak Grey
    func setOptionsTitleColorTo(color: UIColor){
        self.optionsTitleColor = color
    }
    
    private var touchPointColor:UIColor = UIColor.init(hexString: "#424242") //Drak Grey
    func setTouchPointColorTo(color: UIColor){
        self.touchPointColor = color
    }
    
    private var optionsTitleSize:CGFloat = 64
    func setOptionsTitleSizeTo(size: CGFloat){
        self.optionsTitleSize = size
    }
    
    init(options: [JonAction], delegate:JonContextMenuDelegate?=nil){
        super.init(target: self, action: nil)
        
        guard let window = UIApplication.shared.keyWindow else{
            fatalError("No access to UIApplication Window")
        }
        self.window    = window
        self.options   = options
        self._delegate = delegate
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let touch = touches.first!
        showMenu(on: touch.location(in: contextMenuView))
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if let selectedItem = currentItem{
            _delegate?.menuItemWasSelected(selectedItem)
        }
        dissmissMenu()
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        dissmissMenu()
    }
    
    private var currentItem:JonAction?
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch         = touches.first!
        let touchLocation = touch.location(in: contextMenuView)
        
        if let current = currentItem, current.frame.contains(touchLocation){
            if !isActive{
                activate(current)
                _delegate?.menuItemWasActivated(current)
            }
        }
        else{
            if isActive{
                deactivate(currentItem)
                contextMenuView.hideLabel()
                
                currentItem = nil
                _delegate?.menuItemWasDeactivated()
            }
            for action in options{
                if action.frame.contains(touchLocation){
                    currentItem = action
                    break
                }
            }
        }
    }
    
    private func showMenu(on point:CGPoint){
        contextMenuView = JonContextMenuView(frame: window.frame, options: options, point: point)
        
        for action in options{
            deactivate(action)
        }
        
        contextMenuView.touchPointView.borderColor = touchPointColor
        contextMenuView.label.textColor = optionsTitleColor
        contextMenuView.label.font      = UIFont.systemFont(ofSize: optionsTitleSize, weight: .bold)
        contextMenuView.background.alpha           = backgroundAlpha
        contextMenuView.background.backgroundColor = backgroundColor
        
        window.addSubview(contextMenuView)
        _delegate?.menuOpened()
    }
    
    private func dissmissMenu(){
        contextMenuView.removeFromSuperview()
        contextMenuView = nil
        _delegate?.menuClosed()
    }
    
    var isActive = false
    private func activate(_ action:JonAction){
        isActive = true
        action.button.tintColor       = iconActiveColor
        action.button.backgroundColor = buttonActiveColor
        
        contextMenuView.showTitle(action.title)
        UIView.animate(withDuration: 0.2, animations: {
            action.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        })
    }
    
    private func deactivate(_ action:JonAction?){
        guard let action = action else {
            return
        }
        
        isActive = false
        action.button.tintColor       = iconDefaultColor
        action.button.backgroundColor = buttonDefaultColor
        
        UIView.animate(withDuration: 0.2, animations: {
            action.transform = CGAffineTransform.identity
        })
    }
}
