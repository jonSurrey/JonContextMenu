//
//  ViewController.swift
//  JonContextMenu-Example
//
//  Created by Jonathan Martins on 10/09/2018.
//  Copyright © 2018 Surrey. All rights reserved.
//

import UIKit
import JonContextMenu

class ExampleCell: UITableViewCell{
    
    // Cell's text info
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Adds the constraints to the views in this cell
    private func setupConstraints(){
        self.contentView.addSubview(title)
        NSLayoutConstraint.activate([
            title.centerYAnchor .constraint(equalTo: self.contentView.centerYAnchor),
            title.leadingAnchor .constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12)
        ])
    }
    
    /// Configures the cell
    func configureCell(_ title:String, contextMenu:JonContextMenu){
        self.title.text  = title
        self.addGestureRecognizer(contextMenu.build())
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UITableViewController {
    
    private let items = ["Long touch - DEFAULT menu",
                 "Long touch - CUSTOM menu 1",
                 "Long touch - CUSTOM menu 2",
                 "Long touch - CUSTOM menu 3",
                 "Long touch - 8 items and delegates"]
    
    private var options:[JonItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewController()
    }
    
    private func setupTableViewController(){
        self.title = "Example"
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        self.tableView.registerCell(ExampleCell.self)
        self.tableView.tableFooterView = UIView()
    }
    
    /// Converts a valid hexidecimal String value into a colour
    private func getColor(_ color:String)->UIColor{
        return UIColor.init(hexString: color)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.getCell(indexPath, ExampleCell.self) else {
            return UITableViewCell()
        }
        
        let blue   = getColor("#1976d2")
        let green  = getColor("#388e3c")
        let orange = getColor("#e64a19")
        
        options = [JonItem(id: 1, title: "Google"   , icon: UIImage(named:"google")),
                   JonItem(id: 2, title: "Twitter"  , icon: UIImage(named:"twitter")),
                   JonItem(id: 3, title: "Facebook" , icon: UIImage(named:"facebook")),
                   JonItem(id: 4, title: "Instagram", icon: UIImage(named:"instagram"))]
        
        var contextMenu:JonContextMenu!
        switch indexPath.row {
            case 1:
                contextMenu = JonContextMenu()
                    .setItems(options)
                    .setBackgroundColorTo(green)
                    .setItemsDefaultColorTo(blue)
                    .setItemsActiveColorTo(orange)
                    .setItemsTitleColorTo(.black)
            case 2:
                contextMenu = JonContextMenu()
                    .setItems(options)
                    .setBackgroundColorTo(orange)
                    .setItemsDefaultColorTo(green)
                    .setItemsActiveColorTo(blue)
                    .setItemsTitleColorTo(.white)
            case 3:
                contextMenu = JonContextMenu()
                    .setItems(options)
                    .setBackgroundColorTo(blue)
                    .setItemsDefaultColorTo(orange)
                    .setItemsActiveColorTo(green)
                    .setItemsTitleColorTo(.white)
                    .setItemsTitleSizeTo(32)
            case 4:
                options = [JonItem(id: 1, title: "Google"   , icon: UIImage(named:"google")),
                           JonItem(id: 2, title: "Twitter"  , icon: UIImage(named:"twitter")),
                           JonItem(id: 3, title: "Facebook" , icon: UIImage(named:"facebook")),
                           JonItem(id: 4, title: "Instagram", icon: UIImage(named:"instagram")),
                           JonItem(id: 5, title: "Google"   , icon: UIImage(named:"google")),
                           JonItem(id: 6, title: "Twitter"  , icon: UIImage(named:"twitter")),
                           JonItem(id: 7, title: "Facebook" , icon: UIImage(named:"facebook")),
                           JonItem(id: 8, title: "Instagram", icon: UIImage(named:"instagram"))]
                
                contextMenu = JonContextMenu()
                    .setItems(options)
                    .setDelegate(self)
                    .setIconsDefaultColorTo(UIColor.init(hexString: "#212121"))
            default:
                contextMenu = JonContextMenu()
                    .setItems(options)
                    .setIconsDefaultColorTo(UIColor.init(hexString: "#212121"))
        }
        
        cell.configureCell(items[indexPath.row], contextMenu: contextMenu)
        return cell
    }
}

extension ViewController: JonContextMenuDelegate{
    func menuOpened() {
        print("Menu opened")
    }
    
    func menuClosed() {
        print("Menu closed")
    }
    
    func menuItemWasSelected(item: JonItem) {
        let alert = UIAlertController(title: "Menu Item Was Selected", message: "You selected ''\(item.title)'' option!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func menuItemWasActivated(item: JonItem) {
        print("Item \(item.title) was activated")
    }
    
    func menuItemWasDeactivated(item: JonItem) {
        print("Item \(item.title) was activated")
    }
}

