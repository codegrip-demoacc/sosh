//
//  ChatEventListCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/7/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

struct CellData {
    var opened = Bool()
    var type = String()
    var details = [String()]
}

class ChatEventListCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var table_height: NSLayoutConstraint!
    
    var selectCellHandler : (( _ indexPath: IndexPath) -> Void)!
    
    var chatEventTypes = [EventTypeData]()
    var tableViewData = [CellData]()
    
    override func layoutSubviews() {
        for i in 0..<chatEventTypes.count {
            tableViewData.append(CellData(opened: false, type: chatEventTypes[i].type!, details: chatEventTypes[i].details!))
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ChatEventTypeCell", bundle: nil), forCellReuseIdentifier: "ChatEventTypeCell")
        tableView.register(UINib(nibName: "ChatEventDetailCell", bundle: nil), forCellReuseIdentifier: "ChatEventDetailCell")
        tableView.isScrollEnabled = true
        
        tableView.reloadData()
    } 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == tableViewData.count {
            return 1
        } else {
            if tableViewData[section].opened == true {
                return tableViewData[section].details.count + 2
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatEventTypeCell") as! ChatEventTypeCell
            
            if indexPath.section == tableViewData.count {
                cell.type_label.text = "New List"
                cell.plus_img.alpha = 1
            } else {
                cell.type_label.text = tableViewData[indexPath.section].type
                cell.plus_img.alpha = 0
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatEventDetailCell") as! ChatEventDetailCell
            if indexPath.row == tableViewData[indexPath.section].details.count + 1 {
                cell.detail_label.text = "New Item"
                cell.plus_img.alpha = 1
            } else {
                cell.detail_label.text = tableViewData[indexPath.section].details[indexPath.row - 1]
                cell.plus_img.alpha = 0
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (selectCellHandler != nil) {
            selectCellHandler(indexPath)
        }
        if indexPath.section < tableViewData.count {
            if tableViewData[indexPath.section].opened == true {
                if indexPath.row != tableViewData[indexPath.section].details.count + 1 {
                    tableViewData[indexPath.section].opened = false
                    let sections = IndexSet(integer: indexPath.section)
                    tableView.reloadSections(sections, with: .none)
                }
            } else {
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
