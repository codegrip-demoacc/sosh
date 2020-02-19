//
//  EventNameCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class EventNameCell: UITableViewCell {

    @IBOutlet var name_label: UILabel!
    @IBOutlet var badge_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        badge_label.layer.cornerRadius = badge_label.layer.frame.height/2
        badge_label.layer.borderColor = UIColor.blue.cgColor
        badge_label.layer.borderWidth = 1
        badge_label.layer.backgroundColor = ShareData.main_back_green.cgColor
        badge_label.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    } }
