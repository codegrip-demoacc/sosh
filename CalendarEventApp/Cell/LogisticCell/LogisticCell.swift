//
//  LogisticCell.swift
//  CalendarEventApp
//
//  Created by Toshiyuki - iMac on 4/27/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class LogisticCell: UITableViewCell {

    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var detail_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
