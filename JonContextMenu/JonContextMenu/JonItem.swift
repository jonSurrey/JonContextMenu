//
//  JonItem.swift
//  JonContextMenu
//
//  Created by Jonathan Martins on 10/09/2018.
//  Copyright © 2018 Surrey. All rights reserved.
//

import UIKit
import Foundation

@objc open class JonItem:UIView {
    
    private static let vWidth  = 45
    private static let vHeight = 45
    
    /// The id of the item
    open var id:NSInteger?

    /// The title of the item
    @objc open var title:String = ""
    
    /// The data that the item holds
    @objc open var data:Any?
    
    /// The angle that the item will appear
    var angle: CGFloat = 0
    
    /// Indicates if the item is active
    var isActive:Bool = false
    
    /// The icon  of the button
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    /// The button that represents the item
    private let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0 , width: JonItem.vWidth, height: JonItem.vHeight))
        button.fullCircle = true
        button.addDropShadow()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// The warpper for the button and icon
    let wrapper: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0 , width: JonItem.vWidth, height: JonItem.vHeight))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Adds the constraints to the views
    private func setupConstraints(){
        
        wrapper.addSubview(button)
        wrapper.addSubview(icon)
        self.addSubview(wrapper)
        NSLayoutConstraint.activate([
            icon.heightAnchor .constraint(equalToConstant: 20),
            icon.widthAnchor  .constraint(equalToConstant: 20),
            icon.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            icon.centerXAnchor.constraint(equalTo: button.centerXAnchor),

            button.topAnchor     .constraint(equalTo: wrapper.topAnchor     ),
            button.bottomAnchor  .constraint(equalTo: wrapper.bottomAnchor  ),
            button.leadingAnchor .constraint(equalTo: wrapper.leadingAnchor ),
            button.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            
            wrapper.topAnchor     .constraint(equalTo: self.topAnchor     ),
            wrapper.bottomAnchor  .constraint(equalTo: self.bottomAnchor  ),
            wrapper.leadingAnchor .constraint(equalTo: self.leadingAnchor ),
            wrapper.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    @objc public init(id:NSInteger, title:String, icon:UIImage?, data:Any?=nil){
        super.init(frame: CGRect(x: 0, y: 0, width: JonItem.vWidth, height: JonItem.vHeight))
        self.id         = id
        self.data       = data
        self.title      = title
        self.icon.image = icon
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: JonItem.vWidth, height: JonItem.vHeight))
        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Changes the colours of the button and the icon
    @objc func setItemColorTo(_ itemColour:UIColor, iconColor:UIColor?=nil){
        if let colour = iconColor{
            let templateImage = icon.image?.withRenderingMode(.alwaysTemplate)
            icon.image     = templateImage
            icon.tintColor = colour
        }
        else{
            let templateImage = icon.image?.withRenderingMode(.alwaysOriginal)
            icon.image     = templateImage
            icon.tintColor = nil
        }
        button.backgroundColor = itemColour
    }
}
