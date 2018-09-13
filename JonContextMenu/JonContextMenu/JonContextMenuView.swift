//
//  JonContextMenu.swift
//  JonContextMenu
//
//  Created by Jonathan Martins on 10/09/2018.
//  Copyright © 2018 Surrey. All rights reserved.
//

import UIKit
import Foundation

class JonContextMenuView:UIView {
    
    /// Enum to map the direction of the touch
    enum Direction {
        case left
        case right
        case middle
        case up
        case down
    }
    
    /// The title label that display the name of the touched icon
    let label: UILabel = {
        let label = UILabel()
        label.alpha = 0.0
        label.numberOfLines = 1
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// The background of the view
    let background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// The view that represents the users's touch point
    var touchPointView: UIView!
    
    /// The properties configuration for the JonContextMenuView
    private var properties:JonContextMenu!
    
    /// The distance between the touch point and the menu items
    private let distanceToTouchPoint: CGFloat = 25
    
    /// The coordinates the the user touched on the screen
    private var touchPoint:       CGPoint!
    
    /// The X distance from the menu items to the touched point
    private var xDistanceToItem:  CGFloat!
    
 /// The Y distance from the menu items to the touched point
    private var yDistanceToItem:  CGFloat!
    
    /// The direction that the items are supposed to appear
    private var currentDirection: (Direction, Direction)!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(_ properties:JonContextMenu, touchPoint:CGPoint) {
        super.init(frame: UIScreen.main.bounds)
        self.properties = properties
        self.touchPoint = touchPoint
        
        touchPointView   = makeTouchPoint()
        currentDirection = calculateDirections(properties.items[0].wrapper.frame.width)
        
        addSubviews()
        configureViews()
        displayView()
    }
    
    /// Add the background, touch point and title label to the ContextMenuView
    private func addSubviews(){
        
        self.addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor     .constraint(equalTo: self.topAnchor     ),
            background.bottomAnchor  .constraint(equalTo: self.bottomAnchor  ),
            background.leadingAnchor .constraint(equalTo: self.leadingAnchor ),
            background.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        if touchPoint.y > UIScreen.main.bounds.height/2{
            label.frame = CGRect(x: 20, y: touchPoint.y - 200, width: UIScreen.main.bounds.width/1.2, height: 100)
        }
        else{
            label.frame = CGRect(x: 20, y: touchPoint.y + 100, width: UIScreen.main.bounds.width/1.2, height: 100)
        }
        
        self.addSubview(label)
        self.addSubview(touchPointView)
    }
    
    /// Configure the views to start with the properties set in the JonContextMenu class
    private func configureViews(){
        
        /// Sets the default colour of the items
        properties.items.forEach({
            $0.setItemColorTo(properties.buttonsDefaultColor, iconColor: properties.iconsDefaultColor)
        })
        
        /// Sets the touch point colour
        touchPointView.borderColor = properties.touchPointColor
        
        /// Sets the view's background alpha
        background.alpha = properties.backgroundAlpha
        
        /// Sets the views's background colour
        background.backgroundColor = properties.backgroundColor
        
        /// Sets the items' title colour
        label.textColor = properties.itemsTitleColor
        
        /// Sets the size of the items' title
        label.font = UIFont.systemFont(ofSize: properties.itemsTitleSize, weight: .bold)
    }
    
    /// Shows the ContextMenu
    private func displayView(){
        
        calculateDistanceToItem()
        resetItemsPosition()
        anglesForDirection()
        
        for item in properties.items {
            self.addSubview(item)
            animateItem(item)
        }
    }
    
    /// Creates the touch point view
    private func makeTouchPoint()->UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        view.center = touchPoint
        view.backgroundColor = .clear
        view.fullCircle = true
        view.borderWidth = 3
        view.alpha = 0.3
        return view
    }
    
    /// Sets the menu items' position to the user's touch position
    private func resetItemsPosition() {
        properties.items.forEach({
            $0.center = touchPoint
        })
    }
    
    /// Calculates the distance from the user's touch location to the menu items
    private func calculateDistanceToItem() {
        xDistanceToItem = touchPointView.frame.width/2  + distanceToTouchPoint + CGFloat(properties.items[0].frame.width/2)
        yDistanceToItem = touchPointView.frame.height/2 + distanceToTouchPoint + CGFloat(properties.items[0].frame.height/2)
    }
    
    /// Calculates which direction the menu items shoud appear
    private func calculateDirections(_ menuItemWidth: CGFloat) -> (Direction, Direction) {
        
        let touchWidth  = distanceToTouchPoint + menuItemWidth + touchPointView.frame.width
        let touchHeight = distanceToTouchPoint + menuItemWidth + touchPointView.frame.height
        
        let verticalDirection   = determineVerticalDirection  (touchHeight)
        let horisontalDirection = determineHorisontalDirection(touchWidth )
        
        return(verticalDirection, horisontalDirection)
    }
    
    /// Calculates the vertical point that the user touched on the screen
    private func determineVerticalDirection(_ size: CGFloat) -> Direction {
        
        let isBotomBorderOfScreen = touchPoint.y + size > UIScreen.main.bounds.height
        let isTopBorderOfScreen   = touchPoint.y - size < 0
        
        if  isTopBorderOfScreen {
            return .down
        } else if isBotomBorderOfScreen {
            return .up
        } else {
            return .middle
        }
    }
    
    /// Calculates the horizontal point that the user touched on the screen
    private func determineHorisontalDirection(_ size: CGFloat) -> Direction {
        
        let isRightBorderOfScreen = touchPoint.x + size > UIScreen.main.bounds.width
        let isLeftBorderOfScreen  = touchPoint.x - size < 0
        
        if isLeftBorderOfScreen {
            return .right
        } else if  isRightBorderOfScreen {
            return .left
        } else {
            return .middle
        }
    }
    
    /// Calculates which angle the menu items should appear
    private func anglesForDirection() {
        guard let direction = currentDirection else {
            return
        }
        
        switch (direction) {
            case (.down, .right):
                positiveQuorterAngle(startAngle: 0)
                break
            case (.down, .middle):
                positiveQuorterAngle(startAngle: 90)
                break
            case (.middle, .right):
                positiveQuorterAngle(startAngle: 270)
                break
            case (.down, .left):
                negativeQuorterAngle(startAngle: 180)
                break
            case (.up, .right):
                negativeQuorterAngle(startAngle: 0)
                break
            case (.up, .middle), (.up, .left), (.middle,.middle):
                positiveQuorterAngle(startAngle: 180)
                break
            case (.middle, .left):
                positiveQuorterAngle(startAngle: 135)
                break
            default:
                break
        }
    }
    
    /// Calculates the clockwise angle that each of the menu items should appear based on the given start angle
    private func positiveQuorterAngle(startAngle: CGFloat) {
        properties.items.forEach({ item in
            let index = CGFloat(properties.items.index(of: item)!)
            item.angle = (startAngle + 45 * index)
        })
    }
    
    /// Calculates the counterclockwise angle that each of the menu items should appear based on the given start angle
    private func negativeQuorterAngle(startAngle: CGFloat) {
        properties.items.forEach({ item in
            let index = CGFloat(properties.items.index(of: item)!)
            item.angle = (startAngle - 45 * index)
        })
    }
    
    /// Caculates the final position of the mennu items
    private func calculatePointCoordiantes(_ angle: CGFloat) -> CGPoint {
        let x = (touchPoint.x + CGFloat(__cospi(Double(angle/180))) * xDistanceToItem)
        let y = (touchPoint.y + CGFloat(__sinpi(Double(angle/180))) * yDistanceToItem)
        return CGPoint(x: x, y: y)
    }
    
    /// Animates the menu items to appear at the calculated positions
    private func animateItem(_ item: JonItem) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: {
            item.center = self.calculatePointCoordiantes(item.angle)
        }, completion: nil)
    }
    
    /// Activates the selected menu item
    func activate(_ item:JonItem){
        
        item.isActive = true
        item.setItemColorTo(properties.buttonsActiveColor, iconColor: properties.iconsActiveColor)

        let newX = (item.wrapper.center.x + CGFloat(__cospi(Double(item.angle/180))) * 30)
        let newY = (item.wrapper.center.y + CGFloat(__sinpi(Double(item.angle/180))) * 30)
        
        self.label.text = item.title
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: {
            self.label.alpha = 1.0
            item.wrapper.center    = CGPoint(x: newX, y: newY)
            item.wrapper.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: nil)
    }
    
    /// Deactivate the  item
    func deactivate(_ item:JonItem){
        
        item.isActive = false
        item.setItemColorTo(properties.buttonsDefaultColor, iconColor: properties.iconsDefaultColor)
        
        let newX = (item.wrapper.center.x + CGFloat(__cospi(Double(item.angle/180))) * -30)
        let newY = (item.wrapper.center.y + CGFloat(__sinpi(Double(item.angle/180))) * -30)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.label.alpha = 0.0
            item.wrapper.center    = CGPoint(x: newX, y: newY)
            item.wrapper.transform = CGAffineTransform.identity
        })
    }
}
