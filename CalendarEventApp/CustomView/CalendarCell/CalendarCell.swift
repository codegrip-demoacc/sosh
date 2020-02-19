//
//  CalendarCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/8/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import JTAppleCalendar

class CalendarCell: JTAppleCell {
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
}
