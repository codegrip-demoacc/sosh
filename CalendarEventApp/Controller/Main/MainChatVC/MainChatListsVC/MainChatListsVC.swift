//
//  MainChatListsVC.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainChatListsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var chatEventLists = [ChatEventListData]()
    var opened = [[Bool]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dummy_data()
        setupTableView()
    }
    
    //cell click
    func tableViewCellSelectHandler(tableIndex: IndexPath, detailIndex: IndexPath) {
        print(tableIndex.section)
        print(detailIndex.section)
        print(detailIndex.row)

        if detailIndex.section == chatEventLists[tableIndex.section].lists!.count {
            print("Clicked Add New List")
        } else {
            if detailIndex.row == chatEventLists[tableIndex.section].lists![detailIndex.section].details!.count + 1 {
                print("Clicked Add New Item")
            } else {
//                opened[tableIndex.section][detailIndex.section] = !opened[tableIndex.section][detailIndex.section]
//                self.tableView.reloadData()
            }
        }
    }
    
    func dummy_data() {
        var details = [EventTypeData]()
        details.append(EventTypeData(id: "", type: "Groceris", details: ["Hiking", "Hot Spring", "Snappa", "Shoot Milky Way"]))
        details.append(EventTypeData(id: "", type: "Activity Ideas", details: ["Hiking", "Hot Spring", "Snappa"]))
        chatEventLists.append(ChatEventListData(id: "", name: "Tahoe Skip Trip", lists: details))
        details.removeAll()
        details.append(EventTypeData(id: "", type: "Groceris", details: ["Shoot Milky Way", "Hiking", "Hot Spring", "Snappa", "Shoot Milky Way"]))
        details.append(EventTypeData(id: "", type: "Activity Ideas", details: ["Snappa", "Shoot Milky Way", "Hiking", "Hot Spring"]))
        details.append(EventTypeData(id: "", type: "Bar Crawl List", details: ["Hiking", "Hot Spring", "Snappa", "Shoot Milky Way"]))
        chatEventLists.append(ChatEventListData(id: "", name: "Joshua Tree Camping", lists: details))
        for i in 0..<chatEventLists.count {
            var openFirst = [Bool]()
            for _ in 0..<chatEventLists[i].lists!.count {
                openFirst.append(false)
            }
            opened.append(openFirst)
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ChatEventListCell", bundle: nil), forCellReuseIdentifier: "ChatEventListCell")
        tableView.isScrollEnabled = true
        tableView.reloadData()
    }
}

extension MainChatListsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatEventLists.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 30
        height += 50*(chatEventLists[indexPath.section].lists!.count+1)
        for i in 0..<chatEventLists[indexPath.section].lists!.count {
            if opened[indexPath.section][i] {
                height += 30*chatEventLists[indexPath.section].lists![i].details!.count
            }
        }
        print("height  \(height)")
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatEventListCell") as! ChatEventListCell
        cell.name_label.text = chatEventLists[indexPath.section].name
        cell.chatEventTypes = chatEventLists[indexPath.section].lists!
        cell.selectionStyle = .none
        
        var height = 0
        height = 50*(chatEventLists[indexPath.section].lists!.count+1)
        for i in 0..<chatEventLists[indexPath.section].lists!.count {
            if opened[indexPath.section][i] {
                height += 30*chatEventLists[indexPath.section].lists![i].details!.count
            }
        }
        cell.table_height.constant = CGFloat(height)
        cell.selectCellHandler = { ( _ subIndexPath: IndexPath) -> Void in
            self.tableViewCellSelectHandler(tableIndex: indexPath, detailIndex: subIndexPath)
        }
        return cell
    }
}

extension MainChatListsVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Lists")
    }
}
