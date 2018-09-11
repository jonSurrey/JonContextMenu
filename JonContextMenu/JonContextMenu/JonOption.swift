//
//  JonOption.swift
//  JonContextMenu
//
//  Created by Jonathan Martins on 10/09/2018.
//  Copyright © 2018 Surrey. All rights reserved.
//

import UIKit
import Foundation

open class JonAction:UIView {
    
    var angle: CGFloat = 0
    
    open var title:String = ""
    
    //// The button of the menu
    let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0 , width: 45, height: 45))
        button.fullCircle = true
        button.addDropShadow()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// Adds the constraints to the views
    private func setupConstraints(){
        
        self.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor     .constraint(equalTo: self.topAnchor     ),
            button.bottomAnchor  .constraint(equalTo: self.bottomAnchor  ),
            button.leadingAnchor .constraint(equalTo: self.leadingAnchor ),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            button.heightAnchor .constraint(equalToConstant: 45),
            button.widthAnchor  .constraint(equalToConstant: 45)
        ])
    }
    
    public init(title:String, icon:UIImage?){
        super.init(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        button.setImage(icon?.resize(to:20)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.title = title
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
