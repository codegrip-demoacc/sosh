//
//  DayCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/8/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class DayCell: UITableViewCell {

    @IBOutlet weak var name_label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
