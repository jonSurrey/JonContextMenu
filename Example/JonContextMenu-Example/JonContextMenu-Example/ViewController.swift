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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UITableViewController {
    
    let items = ["Long touch - DEFAULT menu",
                 "Long touch - CUSTOM menu 1",
                 "Long touch - CUSTOM menu 2",
                 "Long touch - CUSTOM menu 3",
                 "Long touch - select item delegates"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewController()
    }
    
    private func setupTableViewController(){
        self.title = "Example"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.tableView.registerCell(ExampleCell.self)
        self.tableView.tableFooterView = UIView()
    }
    
    /// Converts a valid hexidecimal String value into a colour
    func getColor(_ color:String)->UIColor{
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
        cell.title.text = items[indexPath.row]
        
        addContextMenuTo(cell, at: indexPath)
        return cell
    }
    
    private func addContextMenuTo(_ cell:UITableViewCell, at indexPath:IndexPath){
        
        let options = [JonAction(title: "Google"   , icon: UIImage(named:"google")),
                       JonAction(title: "Twitter"  , icon: UIImage(named:"twitter")),
                       JonAction(title: "Facebook" , icon: UIImage(named:"facebook")),
                       JonAction(title: "Instagram", icon: UIImage(named:"instagram"))]
        
        let contextMenu = JonContextMenu(options: options)
        
        let blue   = getColor("#1976d2")
        let green  = getColor("#388e3c")
        let orange = getColor("#e64a19")
        
        switch indexPath.row {
            case 1:
                contextMenu.setBackgroundColorTo(color: green)
                contextMenu.setButtonsColor(to: blue, andIconsTo: .white)
                contextMenu.setButtonsActiveColor(to: orange, andIconsTo: .white)
            case 2:
                contextMenu.setBackgroundColorTo(color: orange)
                contextMenu.setButtonsColor(to: green, andIconsTo: .white)
                contextMenu.setButtonsActiveColor(to: blue, andIconsTo: .white)
                contextMenu.setTouchPointColorTo(color: green)
            case 3:
                contextMenu.setBackgroundColorTo(color: blue)
                contextMenu.setButtonsColor(to: orange, andIconsTo: .white)
                contextMenu.setButtonsActiveColor(to: green, andIconsTo: .white)
                contextMenu.setOptionsTitleSizeTo(size: 32)
            case 4:
                contextMenu.set(delegate: self)
            default:
                break
        }
        cell.addGestureRecognizer(contextMenu)
    }
}

extension ViewController: JonContextMenuDelegate, UIGestureRecognizerDelegate{
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func menuOpened() {
  
    }
    
    func menuClosed() {
        
    }
    
    func menuItemWasActivated(_ item: JonAction) {
        
    }
    
    func menuItemWasSelected(_ item: JonAction) {
        let alert = UIAlertController(title: "Menu Item Was Selected", message: "You selected ''\(item.title)'' option!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func menuItemWasDeactivated() {
        
    }
}

