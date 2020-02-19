//
//  ChatEventTypeCell.swift
//  CalendarEventApp
//
//  Created by SunPooh on 5/7/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import UIKit

class ChatEventTypeCell: UITableViewCell {

    @IBOutlet weak var type_label: UILabel!
    @IBOutlet weak var plus_img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
