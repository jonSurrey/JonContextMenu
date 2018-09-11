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

open class JonContextMenu: UILongPressGestureRecognizer{
    
    private var window:UIWindow!
    private var contextMenuView:JonContextMenuView!
    
    private var _delegate:JonContextMenuDelegate?
    open func set(delegate: JonContextMenuDelegate?){
        self._delegate = delegate
    }
    
    private var options:[JonAction] = []
    open func set(options: [JonAction]){
        self.options = options
    }
    
    private var backgroundColor:UIColor = .white
    open func setBackgroundColorTo(color: UIColor){
        self.backgroundColor = color
    }
    
    private var backgroundAlpha:CGFloat = 0.9
    open func setBackgroundAlphaTo(_ alpha:CGFloat){
        self.backgroundAlpha = alpha
    }
    
    private var buttonsDefaultColor:UIColor = .white
    private var iconsDefaultColor:UIColor   = UIColor.init(hexString: "#424242")//Drak Grey
    open func setButtonsColor(to color: UIColor, andIconsTo iconsColor:UIColor){
        self.buttonsDefaultColor = color
        self.iconsDefaultColor   = iconsColor
    }
    
    private var buttonsActiveColor:UIColor = UIColor.init(hexString: "#9a0007") //Red
    private var iconsActiveColor:UIColor   = .white
    open func setButtonsActiveColor(to color: UIColor, andIconsTo iconsColor:UIColor){
        self.buttonsActiveColor = color
        self.iconsActiveColor   = iconsColor
    }
    
    private var optionsTitleColor:UIColor = UIColor.init(hexString: "#424242") //Drak Grey
    open func setOptionsTitleColorTo(color: UIColor){
        self.optionsTitleColor = color
    }
    
    private var touchPointColor:UIColor = UIColor.init(hexString: "#424242") //Drak Grey
    open func setTouchPointColorTo(color: UIColor){
        self.touchPointColor = color
    }
    
    private var optionsTitleSize:CGFloat = 64
    open func setOptionsTitleSizeTo(size: CGFloat){
        self.optionsTitleSize = size
    }
    
    public init(options: [JonAction], delegate:JonContextMenuDelegate?=nil){
        super.init(target: self, action: nil)
        
        guard let window = UIApplication.shared.keyWindow else{
            fatalError("No access to UIApplication Window")
        }
        self.window    = window
        self.options   = options
        self._delegate = delegate
        self.minimumPressDuration = 1.5
    }
    
    private func backViewsScroll(enable:Bool){
        (self.view?.superview as? UITableView)?.isScrollEnabled = enable
        (self.view?.superview as? UIScrollView)?.isScrollEnabled = enable
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        backViewsScroll(enable: false)
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
        backViewsScroll(enable: true)
        
        contextMenuView.removeFromSuperview()
        contextMenuView = nil
        _delegate?.menuClosed()
    }
    
    var isActive = false
    private func activate(_ action:JonAction){
        isActive = true
        action.button.tintColor       = iconsActiveColor
        action.button.backgroundColor = buttonsActiveColor
        
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
        action.button.tintColor       = iconsDefaultColor
        action.button.backgroundColor = buttonsDefaultColor
        
        UIView.animate(withDuration: 0.2, animations: {
            action.transform = CGAffineTransform.identity
        })
    }
}
