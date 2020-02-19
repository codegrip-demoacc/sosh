//
//  EventListCell.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit
import Kingfisher

class EventListCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var date_label: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var table_height: NSLayoutConstraint!
    @IBOutlet var contain_width: NSLayoutConstraint!
    
    var events = [[String: Any]]()
    var selectCellHandler : (( _ indexPath: IndexPath) -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint]) 

        self.date_label.layer.borderColor = UIColor.blue.cgColor
        self.date_label.layer.borderWidth = 1
        self.date_label.layer.cornerRadius = 10
        self.date_label.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        tableView.register(UINib(nibName: "EventListTableVCell", bundle: nil), forCellReuseIdentifier: "EventListTableVCell")
        tableView.isScrollEnabled = false
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
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
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "EventListTableVCell") as! EventListTableVCell
        if events[indexPath.section][event.isPrivate] as! Bool {
            cell.name_label.text = events[indexPath.section][event.name] as? String
            cell.bottom_left_label.text = events[indexPath.section][event.location] as? String
            cell.bottom_right_location_label.alpha = 0
            cell.bottom_right_stackView.alpha = 1
            cell.yes_num_label.text = "\(events[indexPath.section][event.yes] as! Int)"
            cell.no_num_label.text = "\(events[indexPath.section][event.no] as! Int)"
            cell.tbd_num_label.text = "\(events[indexPath.section][event.tbd] as! Int)"
            cell.back_mask.backgroundColor = .green
        } else {
            cell.name_label.text = events[indexPath.section][event.accept] as? String
            cell.bottom_left_label.text = events[indexPath.section][event.name] as? String
            cell.bottom_right_location_label.text = events[indexPath.section][event.location] as? String
            cell.bottom_right_location_label.alpha = 1
            cell.bottom_right_stackView.alpha = 0
            cell.back_mask.backgroundColor = ShareData.mainColors[0]
        }
        //date
        let start_date = events[indexPath.section][event.start_date] as? String
        let end_date = events[indexPath.section][event.end_date] as? String
        if start_date == end_date {
            cell.date_label.text = start_date?.monthAndDay()
        } else {
            cell.date_label.text = (start_date?.monthAndDay())! + " - " + (end_date?.monthAndDay().substring(from: 4))!
        }
        //cell background photo
        let photo = (events[indexPath.section][event.photos] as! [String])[0]
        let url = URL(string: photo)
        let processor = DownsamplingImageProcessor(size: cell.back_img.frame.size) >> RoundCornerImageProcessor(cornerRadius: 5)
        cell.back_img.kf.indicatorType = .activity
        cell.back_img.kf.setImage(with: url, placeholder: UIImage(named: "sky"), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectCellHandler != nil) {
//            let cell = tableView.cellForRow(at: indexPath)
            selectCellHandler(indexPath)
        }
    }
}
