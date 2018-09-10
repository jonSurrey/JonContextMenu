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
    
    /// The title label
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// The view Background
    let background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// The view that represents the users's touch point
    var touchPointView: UIView!
    
    /// the items of the menu
    private var options:[JonAction]!
    
    /// The distance between the touch point and the menu items
    private let distanceToTouchPoint: CGFloat = 20
    
    private var angleCoef:        CGFloat!
    private var touchPoint:       CGPoint!
    private var xDistanceToItem:  CGFloat!
    private var yDistanceToItem:  CGFloat!
    private var currentDirection: (Direction, Direction)!
    
    init(frame: CGRect, options:[JonAction], point:CGPoint) {
        super.init(frame: frame)
        
        
        self.options = options
        touchPoint   = point
        angleCoef    = 90.0 / max(CGFloat(options.count - 1), 1)
        
        createTouchPoint()
        addSubviews()
        createView()
    }
    
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
    
    private func createView(){
        
        calculateDistanceToItem()
        resetItemsPosition()
        anglesForDirection()
        
        for option in options {
            self.addSubview(option)
            animateItem(option)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTouchPoint(){
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        view.center = touchPoint
        view.backgroundColor = .clear
        view.fullCircle = true
        view.borderWidth = 3
        view.alpha = 0.3
        
        touchPointView   = view
        currentDirection = calculateDirections(options[0].button.frame.width)
    }
    
    private func resetItemsPosition() {
        options.forEach({
            $0.center  = touchPoint
        })
    }
    
    private func calculateDistanceToItem() {
        xDistanceToItem = touchPointView.frame.width/2  + distanceToTouchPoint + CGFloat(options[0].button.frame.width/2)
        yDistanceToItem = touchPointView.frame.height/2 + distanceToTouchPoint + CGFloat(options[0].button.frame.height/2)
    }
    
    private func calculateDirections(_ menuItemWidth: CGFloat) -> (Direction, Direction) {
        
        let touchWidth  = distanceToTouchPoint + menuItemWidth + touchPointView.frame.width
        let touchHeight = distanceToTouchPoint + menuItemWidth + touchPointView.frame.height
        
        let verticalDirection   = determineVerticalDirection  (touchHeight, superViewFrame: self.frame)
        let horisontalDirection = determineHorisontalDirection(touchWidth , superViewFrame: self.frame)
        
        return(verticalDirection, horisontalDirection)
    }
    
    private func determineVerticalDirection(_ size: CGFloat, superViewFrame: CGRect) -> Direction {
        
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
    
    private func determineHorisontalDirection(_ size: CGFloat, superViewFrame: CGRect) -> Direction {
        
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
    
    private func positiveQuorterAngle(startAngle: CGFloat) {
        options.forEach({ option in
            let index = CGFloat(options.index(of: option)!)
            option.angle = (startAngle + 45 * index)
        })
    }
    
    private func negativeQuorterAngle(startAngle: CGFloat) {
        options.forEach({ option in
            let index = CGFloat(options.index(of: option)!)
            option.angle = (startAngle - 45 * index)
        })
    }
    
    private func calculatePointCoordiantes(_ angle: CGFloat) -> CGPoint {
        let x = (touchPoint.x + CGFloat(__cospi(Double(angle/180))) * xDistanceToItem)
        let y = (touchPoint.y + CGFloat(__sinpi(Double(angle/180))) * yDistanceToItem)
        return CGPoint(x: x, y: y)
    }
    
    private func animateItem(_ action: JonAction) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: {
            action.center = self.calculatePointCoordiantes(action.angle)
        }, completion: nil)
    }
    
    func showTitle(_ title:String?){
        self.label.text = title
        self.label.alpha = 1.0
    }
    
    func hideLabel(){
        UIView.animate(withDuration: 0.2, animations: {
            self.label.alpha = 0.0
        })
    }
}
