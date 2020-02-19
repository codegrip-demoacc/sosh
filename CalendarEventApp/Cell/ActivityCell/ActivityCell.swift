//
//  ActivityCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/23/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class ActivityCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var date_label: UILabel!
    @IBOutlet var plus_btn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableView_height: NSLayoutConstraint!
    @IBOutlet var contain_width: NSLayoutConstraint!
    
    var details = [[String: String]]()
    var selectCellHandler : (( _ indexPath: IndexPath) -> Void)!
    
    override func layoutSubviews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 40
        tableView.register(UINib(nibName: "ActivityTableVCell", bundle: nil), forCellReuseIdentifier: "ActivityTableVCell")
        tableView.isScrollEnabled = false
        
        tableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ActivityTableVCell") as! ActivityTableVCell
        
        cell.label.text = details[indexPath.section][activity.time]! + " - " + details[indexPath.section][activity.name]!
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectCellHandler != nil) {
            selectCellHandler(indexPath)
        }
    }
}
